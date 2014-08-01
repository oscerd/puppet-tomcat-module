define tomcat::setup (
  $family = undef,
  $update_version = undef,
  $extension = undef,
  $tmpdir = undef,
  $installdir = undef
  ) { 
    
  # Validate parameters presence 
  
  if ($family == undef) {
    fail('family parameter must be set')
  }
  
  if ($update_version == undef) {
    fail('update version parameter must be set')
  }
  
  if ($extension == undef) {
    fail('Extension parameter must be set')
  }
  
  if ($tmpdir == undef){
    notify{'Temp folder not specified, setting default install folder /tmp/':}
    $defined_tmpdir ='/tmp/'
  } else {
    $defined_tmpdir = $tmpdir
  }
  
  # Validate parameters  
  
  if (($family != '6') and ($family != '7') and ($family != '8')) {
    fail('family parameter must be between "6" and "8" included')
  }

  if (($extension != ".tar.gz") and ($extension != ".zip")) {
    fail('Extension parameter must be ".tar.gz" or "zip"')
  }
  
  $tomcat = "apache-tomcat"
  
  file { "${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension}":
		      ensure => present,
		      source => "puppet:///modules/tomcat/${tomcat}-${family}.0.${update_version}${extension}" }

  exec { 'extract_tomcat': 
          command => "tar -xzvf ${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension} -C ${defined_tmpdir}",
          require => [ File[ "${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension}"], 
                       Package['tar'] ], 
          alias => extract_tomcat }
                       
  file { "$installdir":
		      ensure => directory,
		      mode => '755',
		      owner => 'root', 
		      alias => tomcat_home }
  
  exec { 'move_tomcat': 
          command => "mv ${defined_tmpdir}${tomcat}-${family}.0.${update_version}/ ${installdir}",
          require => [ File[ tomcat_home ], 
                       Exec[ extract_tomcat ] ],
                    unless => "ls ${installdir}${tomcat}-${family}.0.${update_version}/" }
}