# +++++ Service configuration +++++ #

# EZB library id e.g. 'TEST3'
$c->{ezb_bibid}= "UBR";

# EZB eprints service adress
$c->{ezb_service_adress} = "http://ezb.ur.de/api/oa_rights";

# SHERPA/RoMEO service adress
$c->{sherpa_service_adress} = "http://www.sherpa.ac.uk/romeo/api29.php";

# SHERPA/RoMEO api key
$c->{sherpa_service_key} = ""; 

# SHERPA/RoMEO issn search service adress
$c->{sherpa_issn_search_adress} = "http://www.sherpa.ac.uk/romeo/search.php"; 
	
# Debug mode
$c->{ezb_debug} = 0;

# +++++ GUI configuration +++++ #

# Show EZB service
$c->{ezb_show_ezb} = 1;

# Show SHERPA/RoMEo service
$c->{ezb_show_sherparomeo} = 1;

# Show German copyright info
$c->{ezb_show_legal_info} = 1;

# Show disclaimer
$c->{ezb_show_disclaimer} = 1;


#support
#University of Regensburg Library
#technik.ezb@ur.de



