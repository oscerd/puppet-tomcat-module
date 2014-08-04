# Params related to conf/server.xml file of Apache Tomcat
#
# Template: templates/serverxml.erb

class tomcat::params{
  
  #Server.xml parameters
  $http_port = "8082"
  $https_port = "8083"
  $ajp_port = "8007"
  $shutdown_port = "8001"
  $http_connection_timeout = "20000"
  $https_max_threads = "150"
}
