<?php

// Site config utf öäü

define("HTML5", true);

error_reporting(E_ALL);  

define ("site_conf","loaded");
$dbdeb=1;
$dbdebs = array();
$dbdat="";
$cffile="";


function out($s)
 {
  global $dbdebs,$dbdeb,$dbdat;
  if($dbdeb)
   { 
     $d=date('c');
     if($d!=$dbdat)
      {
       $dbdebs[] = $d;
       $dbdat=$d;
      } 
     $dbdebs[] = $s; // "D$dbdeb: $s";
   }  
 }



$dbdebneu=0;
$storecookie=false;

// 3 Quellen:  1,Default,  2=cookie, 3 CmdLine
if( isset($_COOKIE['dbdeb']) )
 { 
  $dbdebneu=(int)htmlspecialchars($_COOKIE['dbdeb']);
  out('user.inc.DbDeb from cookie:'.$dbdebneu);
 } 
if( isset($_REQUEST['DbDeb']) )
 {
    $dbdebneu = (int)$_REQUEST['DbDeb'];
    out('user.inc.DbDeb from Url:'.$dbdebneu);
    $storecookie=true;
    // Mysetcookie ("dbdeb", $dbdebneu, time()+3600, $COOKIE_PATH,$COOKIE_DOMAIN );
 }  
if($dbdebneu>0)
 $dbdeb=$dbdebneu;
else $dbdeb=0;  // aus keine Quelle da 


function autoconfig()
{
  global $dbdeb;
  $cfdir=dirname(__FILE__);    

  if($dbdeb>1) out('................ autoconfig..................');
  if($dbdeb>1) out( '_SERVER[SCRIPT_NAME]: '. $_SERVER['SCRIPT_NAME'] );  // logischer name aus URL
  if($dbdeb>1) out( '_SERVER[SERVER_NAME]: '. $_SERVER['SERVER_NAME'] );  // logischer name aus URL
  if($dbdeb>1) out( 'cfdir: '. $cfdir);

  
  $aa= explode('/',$_SERVER['SCRIPT_NAME']);  // logischer name aus URL
  $dlast='';
  foreach($aa as $aaa)
  {
   if(!empty($aaa) && strpos($aaa,'.')===false )  // skip  "xxxbase.de" 
      { $dlast=$aaa; break; } // erster name nach dem eventuellen xxxbase.de (openwb oder web)
   }
  if($dbdeb>1) out("dlast:[$dlast]");

  $cffile = $cfdir ."/" . $dlast . '_'.$_SERVER['SERVER_NAME'].'.conf';
  if($dbdeb>1) out('cffile: '.$cffile);
  return $cffile;
}

$cffile=autoconfig();
if(!(include_once($cffile)))  
    die('There ist no Configuration for this Server ');

if ($storecookie)
    Mysetcookie ("dbdeb", $dbdeb, time()+3600, $COOKIE_PATH,$COOKIE_DOMAIN );

if($dbdeb>1) out('---------- End Autoconfig ----------');


function Mysetcookie($name, $value = null, $expiryTime = 0, $path = null, $domain = null, $secureOnly = false, $httpOnly = true, $sameSiteRestriction = 'Lax' )
{ 
  global $dbdeb;
 $arr_cookie_options = array (
                'expires' => $expiryTime,
                'path' => $path,
                'domain' => $domain,  // leading dot for compatibility or use subdomain
                'secure' => $secureOnly,
                'httponly' => $httpOnly,
                'SameSite' => $sameSiteRestriction
                );
   if($dbdeb>2) out('mysetcookie '.$name.'='.$value.' '.print_r($arr_cookie_options,true));             
   setcookie ($name, $value, $arr_cookie_options );
}



if($dbdeb>0) out( "dbdeb:".$dbdeb);
if($dbdeb>4) out( "iscloud:".$iscloud);
if($dbdeb>4) out( "basedir:".$basedir);
if($dbdeb>4) out( "docroot:".$docroot);
if($dbdeb>4) out( "logdir:".$logdir);

if($dbdeb>9) out('GLOBALS: '.print_r($GLOBALS,true));
else {
    if($dbdeb>6) out("Cookies: " . print_r($_COOKIE,true) );
    if($dbdeb>6) out('GET: '.print_r($_GET,true));
    if($dbdeb>6) out('POST: '.print_r($_POST,true));
    if($dbdeb>6) out('REQUEST: '.print_r($_REQUEST,true));
    if($dbdeb>6) out('SERVER: '.print_r($_SERVER,true));
    }

?>
