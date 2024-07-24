<?php


function GetGET($name,$def)
{
 global $_GET;
 if( isset($_GET[$name]) )
   return $_GET[$name];
 else  
   return $def;
}
function GetPOST($name,$def)
{
 global $_POST;
 if( isset($_POST[$name]) )
   return $_POST[$name];
 else  
   return $def;
}
function GetREQUEST($name,$def)
{
 global $_REQUEST;
 if( isset($_REQUEST[$name]) )
   return $_REQUEST[$name];
 else  
   return $def;
}

function  geturl($file)
{
 global $docroot,$basedir,$dbdeb;
 if($dbdeb>2) Log2File('docroot:'.$docroot,'deb');
 if($dbdeb>2) Log2File('basedir:'.$basedir,'deb');
 if($dbdeb>2) Log2File('file:'.$file,'deb');
 $hn=sprintf('%s%s', $basedir,$file);
 if($dbdeb>2) Log2File('hn:'.$hn,'deb');
 $fn=sprintf('%s/%s', $docroot,$file);
 $ftime=filemtime($fn);
 if($dbdeb>2) Log2File('fn:'.$fn,'deb');
 if($dbdeb>2) Log2File('ftime:'.$ftime,'deb');
 out('try file:'.$fn.' for '.$hn.' time:'.$ftime);
 return sprintf('%s?v=%d' , $hn,$ftime);
}

function Log2File($note,$fn='php')
{
 global $logdir;
 if(is_writeable($logdir))
  {
   $file = $logdir . '/' . $fn .  date("_Y_m")  . ".log";
   $line = sprintf('%s;%s%s',  date('d.m.Y H:i:s'),     $note,"\n");
   error_log($line, 3, $file);
  }
  else out('Log2File:'.$logdir.' nicht beschreibbar');
}




function islogon(string $c)
{
  return false;
}

$fottim="";
function simpleheader()
{
 global $fottim;
 
// header("Content-Security-Policy: default-src 'none'; img-src 'none'; script-src 'none'; style-src 'none'  ");
// header("Content-Security-Policy: default-src 'self' 'unsafe-inline' ;  ");
 header("X-Content-Type-Options: nosniff");
 header("X-Frame-Options: SAMEORIGIN");
 header("X-XSS-Protection: 1; mode=block");
 header("Referrer-Policy: same-origin");
 header("Strict-Transport-Security: max-age=63072000");

 $img=geturl('img/favicons/preloader-image.png');
 echo <<<END
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
</head>
<body>
  	<div style="margin-top: 30px; text-align: center;">
		<div class="row" style="color:black;">
			<div class="mx-auto d-block justify-content-center">
				<img src="$img" style="max-width: 300px" alt="openWB">
		</div>
	</div>

END;
 $fottim="</div>\n";
 }


function footer()
{
  global $dbdebs,$dbdeb,$dbdat,$fottim;
 if( count($dbdebs)>0 && $dbdeb>0 ) 
 {
  echo '<div style="text-align: left;">'; 
  echo'<br><hr><br><div id="dbdeb"  class="OCpanel"  >'. "\n";
  echo'<span id="dbdebArrow" class="OCarrow">&nbsp;'.count($dbdebs).' Lines DbDeb='.$dbdeb.' </span>'. "\n";
  echo '<div>'. "\n";
  echo "<pre>\n";
  foreach( $dbdebs as $s)
     echo "$s\n";
  echo "</pre>\n";
  echo '</div></div></div>'. "\n";
	// $jopts="{ cookied:'showdbdeb', collapsed:true, speed:'50', closedArrow:'$DOGBASE_URL/images/collapsed.gif', openArrow:'$DOGBASE_URL/images/expanded.gif', arrowtitel:'".$L['ShowHide']."' }";
	// $JSSCRIPT[]="  $('#dbdeb').OCpanel($jopts); \n";
 }
 
 echo $fottim;
 echo "</body></htnl>\n";
}


function cleanstring($string) 
{
	$s = trim($string); 
	//$s = htmlentities($s, ENT_QUOTES); 
	$s = str_replace("\n", "<br>", $s);
	if( $string != $s )
       Log2File("String [$string] cleaned to :[$s]:" , 'debug');
	return $s;
}


function detect_ie()
{
    if (isset($_SERVER['HTTP_USER_AGENT']) &&
    (strpos($_SERVER['HTTP_USER_AGENT'], 'MSIE') !== false))
        return true;
    else
        return false;
}



function mybuild_http_query( $query )
{
    $query_array = array();
    foreach( $query as $key => $key_value ){
        $query_array[] = urlencode( $key ?: '') . '=' . urlencode( $key_value ?: '' );
    }
    return implode( '&', $query_array );
}

// for Cookies only on this Site
function xencrypt($data, $key)
{
 $l = strlen($key);
 if ($l < 16)
  {
    $key = str_repeat($key, ceil(16/$l));
    out('repeated key now '.$key);
  }   
 if ($m = strlen($data)%8)
  {
    $data .= str_repeat("\x00",  8 - $m);
   //out("data ($m)now:($data)".print_r($data,true));
  }    
   if( PHP_VERSION_ID < 80000 )
     {
       $val = openssl_encrypt($data, 'BF-ECB', $key, OPENSSL_RAW_DATA | OPENSSL_NO_PADDING);
       out('encrypt with openssl.7');
     } else
     {
     $val = openssl_encrypt($data, 'AES-128-CTR', $key, OPENSSL_RAW_DATA | OPENSSL_NO_PADDING,openssl_encrypt_IV);
       out('encrypt with openssl.8');
     }
 return $val;
}

// for Cookies only on this Site
function xdecrypt($data, $key)
{
 $l = strlen($key);
 if ($l < 16)
 {
      $key = str_repeat($key, ceil(16/$l));
       out('repeated key now '.$key);
 }     

   if( PHP_VERSION_ID < 80000 )
   {
     $val = openssl_decrypt($data, 'BF-ECB', $key, OPENSSL_RAW_DATA | OPENSSL_NO_PADDING);
     out('decrypt with openssl.7');
   }  
   else
   {
     $val = openssl_decrypt($data, 'AES-128-CTR', $key, OPENSSL_RAW_DATA | OPENSSL_NO_PADDING,openssl_encrypt_IV);
     out('decrypt with openssl.8');
   }
 return $val;
}


function xencrypt8($data, $key)
{
  global $dbdeb;
 
 $l = strlen($key);
 if ($l < 16)
  {
    $key = str_repeat($key, ceil(16/$l));
    //$key = substr($key,0,16);
    out('repeated key now '.$key . "  ". strlen($key) );
  }   
 if ($m = strlen($data)%8)
  {
    $data .= str_repeat("\x00",  8 - $m);
   //out("data ($m)now:($data)".print_r($data,true));
  }    

   if (function_exists('openssl_encrypt') )
    {
      $val = openssl_encrypt($data, 'AES-128-CTR', $key, OPENSSL_RAW_DATA | OPENSSL_NO_PADDING,openssl_encrypt_IV);
     out('coded in '.strlen($val).' bytes');
// breed=ESS&id=259810&modes=3&vmodes=&smode=&dlgw=560&_ip=127.0.0.1&_uid=2253&_time=1691863624
// coded in 96 bytes     
    }
    else 
    {
     $val=$data;
     out('no coder avail');
 }    
 return $val;
}

 

function xdecrypt8($data, $key)
{
 $l = strlen($key);
 if ($l < 16)
 {
    $key = str_repeat($key, ceil(16/$l));
    //$key = substr($key,0,16);
    out('repeated key now '.$key . "  ". strlen($key) );
  }    
    $val = openssl_decrypt($data, 'AES-128-CTR', $key, OPENSSL_RAW_DATA | OPENSSL_NO_PADDING,openssl_encrypt_IV);
 out('decoded to '.strlen($val).' bytes');
 return $val;
}
    


if($dbdeb>6) out("Cookies: " . print_r($_COOKIE,true) );
if($dbdeb>6) out('GET: '.print_r($_GET,true));
if($dbdeb>6) out('POST: '.print_r($_POST,true));
if($dbdeb>6) out('REQUEST: '.print_r($_REQUEST,true));
if($dbdeb>6) out('SERVER: '.print_r($_SERVER,true));
//if($dbdeb>6) out('GLOBALS: '.print_r($GLOBALS,true));


?>
