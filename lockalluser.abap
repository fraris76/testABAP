*&———————————————————————*
*& Report YUSRLOCK *
*& *
*&———————————————————————*
*& *
*& *
*&———————————————————————*
REPORT YUSRLOCK MESSAGE-ID Z1 .
TABLES: USR02.
PARAMETERS: LOCK AS CHECKBOX, LISTLOCK AS CHECKBOX.
DATA: UFLAGVAL TYPE I, LOCKSTRING(8) TYPE C.
*————– Authorization check ———————–*
AUTHORITY-CHECK OBJECT ‘ZPROG_RUN’ ID ‘PROGRAM’ FIELD SY-CPROG.
IF SY-SUBRC <> 0.
IF SY-SUBRC = 4.
MESSAGE E000 WITH SY-CPROG. “some message about authorization check failure
ELSE.
MESSAGE E005 WITH SY-SUBRC. “some message about authorization check failure
ENDIF.
ENDIF.
IF LISTLOCK = ‘X’.
WRITE:/ ‘List all locked users: ‘.
SELECT * FROM USR02 WHERE UFLAG = 64.
WRITE: / USR02-BNAME.
ENDSELECT.
EXIT.
ENDIF.
IF LOCK = ‘X’.
UFLAGVAL = 64. “lock all users
LOCKSTRING = ‘locked’.
ELSE.
UFLAGVAL = 0. “unlock all users
LOCKSTRING = ‘unlocked’.
ENDIF.
SELECT * FROM USR02 WHERE BNAME <> ‘SAP*’ AND BNAME <> SY-UNAME.
IF USR02-UFLAG <> 0 AND USR02-UFLAG <> 64.
WRITE: ‘User’, USR02-BNAME, ‘untouched; please handle manually.’.
CONTINUE.
ENDIF.
** check that user has authority to make these changes
AUTHORITY-CHECK OBJECT ‘S_USER_GRP’
ID ‘CLASS’ FIELD USR02-CLASS
ID ‘ACTVT’ FIELD ’05’.
IF SY-SUBRC <> 0.
IF SY-SUBRC = 4.
WRITE: /’You are not authorized to lock/unlock user ‘,
USR02-BNAME, USR02-CLASS.
ELSE.
WRITE: /’Authorization error checking user ‘,
USR02-BNAME, USR02-CLASS, ‘(return code’, SY-SUBRC, ‘).’.
ENDIF.
ELSE. “has authority
UPDATE USR02 SET UFLAG = UFLAGVAL WHERE BNAME = USR02-BNAME.
WRITE: / ‘User’, USR02-BNAME, LOCKSTRING, ‘.’.
ENDIF.
