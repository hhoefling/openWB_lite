<?php
# Never no Link, only manueller direct-Link
if(isset($_POST["testlp1"])  || isset($_GET["testlp1"])  ) {
	file_put_contents('/var/www/html/openWB/ramdisk/evsedintestlp1', ausstehend);
}
if(isset($_POST["testlp2"]) || isset($_GET["testlp2"]) ) {
	file_put_contents('/var/www/html/openWB/ramdisk/evsedintestlp2', ausstehend);
}
if(isset($_POST["testlp3"]) || isset($_GET["testlp3"]) ) {
	file_put_contents('/var/www/html/openWB/ramdisk/evsedintestlp3', ausstehend);
}

header("Location: ../status/status.php");
?>
