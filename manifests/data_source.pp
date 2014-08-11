# Params related to data source file of Apache Tomcat
#
# Template: templates/serverxml.erb and context.xml

class tomcat::data_source{
  
  # Datasource
  
  # Set Name
  $ds_resource_name = "jdbc/ExampleDB"

  # Set MaxActive
  $ds_max_active = "100"
  
  # Set MaxIdle
  $ds_max_idle = "20"
  
  # Set MaxWait
  $ds_max_wait = "10000"
  
  # Set username
  $ds_username = "username"

  # Set password
  $ds_password = "password"
  
  # Set driver class name
  $ds_driver_class_name = "oracle.jdbc.OracleDriver"
  
  # Url variable
  $ds_driver = "jdbc"
  $ds_dbms = "oracle"
  $ds_host = "192.168.52.128"
  $ds_port = "1521"
  $ds_service = "example"
  
  # Complete URL
  $ds_url = "${ds_driver}:${ds_dbms}:thin:@${ds_host}:${ds_port}/${ds_service}"
}