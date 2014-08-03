# Params related to conf/server.xml file of Apache Tomcat
#
# Template: templates/serverxml.erb

class tomcat::params{
  $http_port = "8082"
  $https_port = "8083"
  $ajp_port = "8007"
}