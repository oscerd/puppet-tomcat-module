# Params related to conf/server.xml file of Apache Tomcat
#
# Template: templates/serverxml.erb

class tomcat::params{
  
  # Server.xml parameters
  
  # Set http port in serverxml.erb
  $http_port = "8082"
  
  # Set https port in serverxml.erb
  $https_port = "8083"
  
  # Set ajp port in serverxml.erb
  $ajp_port = "8007"
  
  # Set shutdown port in serverxml.erb
  $shutdown_port = "8001"
  
  # Set connection timeout in http connector in serverxml.erb
  $http_connection_timeout = "20000"
  
  # Set max threads in https connector in serverxml.erb
  $https_max_threads = "150"
  
  # Datasource
  
  # Set Name
  $ds_resource_name = ""

  # Set MaxActive
  $ds_max_active = ""
  
  # Set MaxIdle
  $ds_max_idle = ""
  
  # Set MaxWait
  $ds_max_wait = ""
  
  # Set username
  $ds_username = ""

  # Set password
  $ds_password = ""
}
