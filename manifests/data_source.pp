# Params related to data source file of Apache Tomcat
#
# Template: templates/serverxml.erb and context.xml

class tomcat::data_source{
  
  # Datasource
  
  # Set Name
  $ds_resource_name = "p"

  # Set MaxActive
  $ds_max_active = "p"
  
  # Set MaxIdle
  $ds_max_idle = "p"
  
  # Set MaxWait
  $ds_max_wait = "p"
  
  # Set username
  $ds_username = "p"

  # Set password
  $ds_password = "p"
}