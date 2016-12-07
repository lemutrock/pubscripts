#!/usr/bin/php
<?php
$content = file_get_contents('http://yandex.ru/internet/');
$myip = explode('</span>',explode('<strong>IPv4-адрес</strong>: <span class="info__value info__value_type_ipv4">',$content)[1])[0];
echo $myip."\n";
$myfile = fopen("{$_SERVER['HOME']}/Yandex.Disk/my.ip", "w");
fwrite($myfile, $myip."\n");
fclose($myfile);
?>
