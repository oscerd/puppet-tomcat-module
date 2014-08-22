# tomcat::config contains the path of all the conf/ folder file

class tomcat::config{
  $server_xml = "/conf/server.xml"
  $context_xml = "/conf/context.xml"
  $users_xml = "/conf/tomcat-users.xml"
}