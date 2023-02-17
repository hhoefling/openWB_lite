
Testen ob eine Varaibale definiert ist derren Namen in einer anderen Variablen steht.
Also kein konstanter Name. z.b wenn der Name Teil einer Namensliste ist

```
declare -n pointertovar=$varname
if ${pointertovar+"false"}
then
   echo "$varname is not set"
else
   echo "varname:$varname , pointertovar $pointertovar"
fi


irgendeinevar="etwasdrin"
varname="irgendeinevar"

declare -n pointertovar=$varname
if ${pointertovar+"false"}
then
   echo "$varname is not set"
else
   echo "varname:$varname , pointertovar $pointertovar"
fi


```
Liefert:
```
irgendeinevar is not set
varname:irgendeinevar , pointertovar etwasdrin
```

