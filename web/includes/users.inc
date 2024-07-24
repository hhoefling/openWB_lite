<?php


class User {
  var $id;
  var $status;
  var $referer;
  var $dirty;
  var $ip;  // from cokie
  var $IPnr; // from connection
  var $username;
  var $passwd;
  var $agent;
  var $agentIp;
  var $thema;
    
  public function __construct()
  {
    $this->dirty = false;
    $this->agent='';
    $this->agentIP='';
    $this->thema='standard';
    $this->dirty=false;
    $this->status='created.';
    $this->id=0;
    
  }

  public function encrypt($text)
  {
   global $COOKIE_KEY,$dbdeb;
   
   if($dbdeb>4) out('encrypt1:'.$text);
   $text .= '#~#END';
   if($dbdeb>4) out('encrypt2:'.$text);
   $text = urlencode($text);     
   if($dbdeb>4) out('encrypt3:'.$text);
   if( isset($COOKIE_KEY) )
    $text=trim(
           base64_encode(
              xencrypt($text,$COOKIE_KEY)
              )
           );
   if($dbdeb>4) out('encrypt4:'.$text);
   return $text;     
  }
  
  public function decrypt($text)
  {
   global $COOKIE_KEY,$dbdeb;
   if($dbdeb>4) out('decrypt1:'.$text);
  
   if( !empty($text) && isset($COOKIE_KEY) )
	   $text=trim(
	           xdecrypt(base64_decode($text),$COOKIE_KEY)
         );
         
   if($dbdeb>4) out('decrypt2:'.$text);
   $text = urldecode($text);     
   if($dbdeb>4) out('decrypt3:'.$text);
    $text = rtrim($text);
   if($dbdeb>4) out('decrypt4:'.$text);
    $a = explode('#~#', $text);
    if( count($a) <2 )
      {
       out("decrypt no #~#");
       out("$text");
       return false;
      }
   if($dbdeb>4) out('decrypt5:'.$a[0]);
   return $a[0];   
  }

  public function set_cookie($name,$val,$expire) 
	{
    global $USER_COOKIE,$COOKIE_PATH,$COOKIE_DOMAIN;
    Out("setcookie([$name],[$val],[$expire],[$COOKIE_PATH],[$COOKIE_DOMAIN]);");
    
       $arr_cookie_options = array (
                'expires' => time() + 60*60*24*30,
                'path' => $COOKIE_PATH,
                'domain' => $COOKIE_DOMAIN,  // leading dot for compatibility or use subdomain
                'secure' => false,     // or false
                'httponly' => false,    // or false
                'samesite' => 'Lax'
                );
       setcookie($name,$val,$arr_cookie_options);
  }

  function init()
	{                                         			
    global $dbdeb;
    global $USER_COOKIE,$_COOKIE,$COOKIE_KEY;
    

    $cookie = $_COOKIE[$USER_COOKIE];
    $cookie = $this->decrypt($cookie);
    $cookie = rtrim($cookie);
    out('init-from cookie:');
    $a = explode('&', $cookie);
    $i = 0;
    //$this->id=-1; // falls cockie fehlerhaft
    //$this->uid=-1; // falls cockie fehlerhaft
    $this->ip=''; // falls cockie fehlerhaft
    while ($i < count($a)) 
		{
      $b = explode ('=', $a[$i]);
      if(count($b)<2) break;
      $key = urldecode($b[0]);
      $value = urldecode($b[1]);
      if( $key=='ip')
	       	$this->{$key} = 	$value = stripslashes($value); 
	  else if ($key=='id' )
	       $this->{$key} = 	(int)$value = stripslashes($value); 
	  else if ($key=='username' )
	       $this->{$key} = 	$value = stripslashes($value); 
	  else if ($key=='passwd' )
	       $this->{$key} = 	$value = stripslashes($value); 
	  else if ($key=='thema' )
	       $this->{$key} = 	$value = stripslashes($value); 
      $i++;
    }
  }


  function set_user_cookie() 
	{
    global $USER_COOKIE,$COOKIE_PATH,$COOKIE_DOMAIN,$COOKIE_KEY;
    $this->IPnr = $_SERVER['REMOTE_ADDR'];
    $cookie = sprintf("id=%d&ip=%s&username=%s&passwd=%s&thema=%s", 
    $this->id, $this->IPnr,$this->username,$this->passwd, $this->thema);
    Out('set User Cookie Name:['.$USER_COOKIE.'] Valu:['.$cookie.'] Path:['.$COOKIE_PATH.'] Domain:['.$COOKIE_DOMAIN.']');

    $cookie = $this->encrypt($cookie);
	if($this->id == 0) // anon?                
      $expire = (time() + (3600 * 1)); // 1 stunde mit refresh bei "newest" 
	else
      $expire = (time() + (3600 * 24 * 1)); // 1 Tag mit refresh bei "newest"

    Out('set User Cookie Name:['.$USER_COOKIE.'] Valu:['.$cookie.'] Path:['.$COOKIE_PATH.'] Domain:['.$COOKIE_DOMAIN.']');

    if(!detect_ie())
     {                                                                    // httponly
      Mysetcookie($USER_COOKIE,$cookie,$expire,$COOKIE_PATH,$COOKIE_DOMAIN);
     } else
     {
      setcookie($USER_COOKIE,$cookie,$expire,'/');
     }
  }

  

  function unset_user_cookie() 
	{
    global $USER_COOKIE,$COOKIE_PATH,$COOKIE_DOMAIN;
    Out('clr User Cookie Name:['.$USER_COOKIE.'] Valu:[] Path:['.$COOKIE_PATH.'] Domain:['.$COOKIE_DOMAIN.']');
    setcookie($USER_COOKIE,"",(time() - 3600),$COOKIE_PATH,$COOKIE_DOMAIN,false,true);
    setcookie($USER_COOKIE,"",(time() - 3600),'/',$COOKIE_DOMAIN);
    $this->id=-1;
    $this->username='';
    $this->passwd='';
    $this->dirty=false;
    
  }

} // class


// This code is run every single time and initializes the
// $_CURRENT_USER object
$_CURRENT_USER = new User;
if(isset($_SERVER['HTTP_REFERER']))
 { 
   	 $_CURRENT_USER->referer= cleanstring($_SERVER['HTTP_REFERER']);
   	 if(strpos($_CURRENT_USER->referer, $COOKIE_DOMAIN)!==FALSE)
       $_CURRENT_USER->referer='self';
  }
  else $_CURRENT_USER->referer='/';


if($dbdeb>2) Out("referer: " . $_CURRENT_USER->referer );

if (isset($_COOKIE[$USER_COOKIE]))
 {
   // User Wiedererkennen
    $_CURRENT_USER->init();
    if(   ($_CURRENT_USER->ip == $_SERVER['REMOTE_ADDR'] )
       && ($_CURRENT_USER->id >0)
       && isset($_CURRENT_USER->thema) )
     { 
        $_CURRENT_USER->status  .=  " valid";
     } else
        $_CURRENT_USER->status  .=  " invalid";
  } else
  {
   if($iscloud===false)
    {
        out('init alone');
        $_CURRENT_USER->id=1;
        $_CURRENT_USER->username='';
        $_CURRENT_USER->passwd='';
        if( isset($_COOKIE['openWBTheme']) )
        { 
            $_CURRENT_USER->thema = htmlspecialchars($_COOKIE['openWBTheme']);
            out('users. Thema from cookie:'.$_CURRENT_USER->thema);
        } 
    }
    else out('No init , use login');
  }

if( $_CURRENT_USER->dirty )
    $_CURRENT_USER->set_user_cookie();

 Out("CU22:".print_r($_CURRENT_USER,true));
 

?>