folgende Befehle setzen unter Windows mit github-Desktop
die Dateirechte der Scripts.

Mit git-Bash:
```` 
 find . -name "*.py" -exec git update-index --chmod=+x {}  \;
 find . -name "*.sh" -exec git update-index --chmod=+x {}  \;
 git commit -m "mode set"
 git push

 
```` 
