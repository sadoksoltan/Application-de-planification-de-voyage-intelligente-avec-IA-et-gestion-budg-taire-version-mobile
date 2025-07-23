<?php
namespace App\Helpers;
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;
use PHPMailer\PHPMailer\SMTP;
class CMail{
public static function send($config){

$mail = new PHPMailer(true);

try {
    //Server settings
    $mail->SMTPDebug = 0;                  
    $mail->isSMTP();                                            //Send using SMTP
    $mail->Host       = config('services.mail.host');                     //Set the SMTP server to send through
    $mail->SMTPAuth   = true;                                   //Enable SMTP authentication
    $mail->Username   = config('services.mail.username');                     //SMTP username
    $mail->Password   = config('services.mail.password');                                //SMTP password
    $mail->SMTPSecure = config('services.mail.encryption');            //Enable implicit TLS encryption
    $mail->Port       = config('services.mail.port');                                   //TCP port to connect to; use 587 if you have set `SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS`

    //Recipients
    $mail->setFrom(
      isset($config['from_address'])? $config['from_address'] : config('services.mail.from_addrees')
      ,
      isset($config['from_name'])? $config['from_name'] : config('services.mail.from_name')
    );
    $mail->addAddress($config['recipient_address'], isset($config['recipient_name'])?
    $config['recipient_name']:null
  
  ); 

    //Content
    $mail->isHTML(true);                                  //Set email format to HTML
    $mail->Subject = $config['subject'];
    $mail->Body    = $config['body'];

    if($mail->send()) {
      return false;
    }else{
      return true;
    }
} catch (Exception $e) {
    echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
}


}



}