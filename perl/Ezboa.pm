package EPrints::Plugin::InputForm::Component::Ezboa;

use EPrints::Plugin::InputForm::Component;
@ISA = ('EPrints::Plugin::InputForm::Component');

use strict;

use Data::Dumper;


sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );
	
	$self->{name} = "Ezboa";
	$self->{visible} = "all";

	return $self;
}

sub has_help
{
	my( $self, $surround ) = @_;
	return $self->{session}->get_lang->has_phrase( $self->html_phrase_id( "help" ) );
}

sub render_help
{
	my( $self, $surround ) = @_;
	return $self->html_phrase( "help" );
}

sub render_title
{
	my( $self, $surround ) = @_;
	return $self->html_phrase( "title" );
}

sub is_required
{
	my( $self ) = @_;
	return 0;
}

sub get_fields_handled
{
	my( $self ) = @_;

	return ( "documents" );
}

sub check_ezboa
{	
	my( $self ) = @_;

	my $session = $self->{session};

	# ****Get plugin configuration****
	# EZB library id
	my $lib_id = $session->get_repository->get_conf("ezb_bibid");

	# EZB eprints service adress
	my $ezb_service_adress = $session->get_repository->get_conf("ezb_service_adress");

	# EZB language
	my $lang = $self->{session}->{lang}->{id};

	# Debug mode
	my $debug =  $session->get_repository->get_conf("ezb_debug");
	# ****END plugin configuration****

	my $ezboa = $session->make_doc_fragment;
	
	#Get title
	my $title = $self->{dataobj}->get_value("title");
       
	# Get ISSN
	#my @issns = $self->{dataobj}->get_value("issn");
	my  $issn = $self->{dataobj}->get_value("issn");
	#my $issn = $issns[0][0];

	# Get DOI
	#my @dois = $self->{dataobj}->get_value("id_number");
	my $doi = $self->{dataobj}->get_value("id_number");
	#my $doi = $dois[0][0]{name};

	my $date = $self->{dataobj}->get_value("date");

	my $div_ep_toolbox = $session->make_element( "div", class=>"ep_toolbox" );
	my $div_ep_toolbox_title = $session->make_element( "div", class=>"ep_toolbox_title" );

	my $div_ep_toolbox_content = $session->make_element( "div", class=>"ep_toolbox_content" );
        $div_ep_toolbox_content->appendChild( $div_ep_toolbox_title );
	$div_ep_toolbox->appendChild( $div_ep_toolbox_content );
	$ezboa->appendChild( $div_ep_toolbox );


		my $wrapper_div = $session->make_element("div", id=>"ezboa");
		my $url;
		
		# case issn is set
		if ($issn ne ''){	
			$url = $ezb_service_adress . "?bibid=" . $lib_id . "&issn=" . $issn . "&year=" . $date . "&lang=" . $lang . "&format=application/xml";
		}
		# case doi is set, overwrite url and continue
		if ($doi ne ''){	
        		$url = $ezb_service_adress . "?bibid=" . $lib_id . "&doi=" . $doi . "&year=" . $date . "&lang=" . $lang  . "&format=application/xml";
		}
		# last resort: check oa rights by title
		if (($issn eq '') and ($doi eq '')){
			$url = $ezb_service_adress . "?bibid=" . $lib_id . "&title=" . $title . "&year=" . $date . "&lang=" . $lang  . "&format=application/xml";
		}
		$url = $url . '&db=live';
		my $xml = EPrints::XML::parse_url( $url );	
		
		if ($debug){
			my $heading_debug = $session->make_element( "h4" );
			$heading_debug->appendChild( $session->make_text( "-------- DEBUG INFORMATION --------" ) );
			$wrapper_div->appendChild( $heading_debug );	

			my $heading_link = $session->make_element( "h4" );
			$heading_link->appendChild( $session->make_text( "REST Link: " ) );
			$wrapper_div->appendChild( $heading_link );	

			my $link = $session->render_link($url);
			$link->appendChild($session->make_text( $url ));
			$wrapper_div->appendChild($link);

			my $heading_xml = $session->make_element( "h4" );
			$heading_xml->appendChild( $session->make_text( "XML Output: " ) );
			$wrapper_div->appendChild( $heading_xml );	

			my $xml_string = $session->make_element( "p" );
			$xml_string->appendChild($session->make_text( $xml ));
			$wrapper_div->appendChild($xml_string);
			
			my $heading_title = $session->make_element( "h4" );
			$heading_title->appendChild( $session->make_text( "Specified title: " ) );
			$wrapper_div->appendChild( $heading_title );	

			my $title_p = $session->make_element( "p" );
			$title_p->appendChild($session->make_text( $title ));
			$wrapper_div->appendChild($title_p);

			my $heading_issn = $session->make_element( "h4" );
			$heading_issn->appendChild( $session->make_text( "Specified ISSN: " ) );
			$wrapper_div->appendChild( $heading_issn );

			my $title_issn = $session->make_element( "p" );
			$title_issn->appendChild($session->make_text( $issn ));
			$wrapper_div->appendChild($title_issn);

			my $heading_lang = $session->make_element( "h4" );
			$heading_lang->appendChild( $session->make_text( "Language: " ) );
			$wrapper_div->appendChild( $heading_lang );	

			my $title_lang = $session->make_element( "p" );
			$title_lang->appendChild($session->make_text( $lang ));
			$wrapper_div->appendChild($title_lang);
		
			my $heading_doi = $session->make_element( "h4" );
			$heading_doi->appendChild( $session->make_text( "Specified DOI: " ) );
			$wrapper_div->appendChild( $heading_doi );	

			my $p_message = $session->make_element( "p" );
			$p_message->appendChild( $session->make_text( $doi ) );
			$wrapper_div->appendChild( $p_message );
			
			my $heading_debug_end = $session->make_element( "h4" );
			$heading_debug_end->appendChild( $session->make_text( "-------- END DEBUG INFORMATION --------" ) );
			$wrapper_div->appendChild( $heading_debug_end );	
		}
			
		#https://stackoverflow.com/questions/39913587/how-to-get-the-text-contents-of-an-xml-child-element-based-on-an-attribute-of-it
		#my $img_ezb = $session->make_element( "img", src=>"/images/Elektronische_Zeitschriftenbibliothek_(Logo).jpg", class=>"ezb_logo");
		#$wrapper_div->appendChild( $img_ezb );
	

		
	my $state = $xml->findnodes('//oa/right/state')->item(0)->textContent;
	my $showhook = 0;
	if ($state eq '0' or $state eq '1'){
		$showhook = 1;
	} 
	
	#my $oa_heading = "OA-Verwertungsrechte aus Allianz-/ Nationallizenzen";
	my $oa_heading = $xml->findnodes('//oa/right/message')->item(0)->textContent;
	my $oa_heading_h1 = $session->make_element("h1");
	$oa_heading_h1->appendChild($session->make_text($oa_heading));
	#$wrapper_div->appendChild($oa_heading_h1);

	my $ezb_logo = $session->make_element( "img", src=>$self->html_phrase( "logo_path" ), class=>"ezb_logo"); 
	my $heading_table = $session->make_element("table");
	my $heading_row = $session->make_element("tr");
	my $heading_cell = $session->make_element("td", class=>"ezb_logo_cell");
	my $logo_cell = $session->make_element("td");
	if ($showhook eq 1){
		my $hook_cell = $session->make_element("td");
		my $img_oa_available = $session->make_element( "img", src=>"/images/oa_rights_available.png", class=>"oa_available" );
		$hook_cell->appendChild($img_oa_available);
		$heading_row->appendChild($hook_cell);
	} else {
		my $hook_cell = $session->make_element("td", class=>"hook_cell");
		my $img_oa_not_available = $session->make_element( "img", src=>"/images/oa_rights_not_available.svg" );
		$hook_cell->appendChild($img_oa_not_available);
		$heading_row->appendChild($hook_cell);
	}
	$heading_cell->appendChild($oa_heading_h1);
	$logo_cell->appendChild($ezb_logo);
	$heading_row->appendChild($heading_cell);
	$heading_row->appendChild($logo_cell);
	$heading_table->appendChild($heading_row);
	$wrapper_div->appendChild($heading_table);

	my $bar_hr = $session->make_element("hr");
	$wrapper_div->appendChild($bar_hr);

	my $index = 0;
	my $number_of_entries = scalar(@{$xml->findnodes('//oa/right')});

	
	foreach my $right_element ($xml->findnodes('//oa/right')){
		#TODO: für Schleife anpassen!
		if ($issn ne '' && ($xml->findnodes('//oa/right/state')->item(0)->textContent + 0) eq 5 ){
			$url = $ezb_service_adress . "?bibid=" . $lib_id . "&issn=" . $issn . "&year=" . $date . "&lang=" . $lang . "&format=application/xml";
			$xml = EPrints::XML::parse_url( $url );
		}

		#OA rights available	
		if (($right_element->findnodes('//right/state')->item(0)->textContent + 0) <= 1){

			if ($debug){
				my $test_p = $session->make_element( "p" );
				my $testmessage = $session->make_text($right_element->findnodes('//right/oa_repositories')->item($index));
				#->findnodes('//right/oa_agreement')->item(0)->textContent; 
				$test_p->appendChild($testmessage);
				$wrapper_div->appendChild($test_p);
			}

			my $number_of_rights = '';
			if ($number_of_entries >= 2){
				$number_of_rights = '(' . ($index+1)  . ') ';
			}

			my $publication_conditions = $session->make_text($self->html_phrase("publication_conditions"));
			my $message = $session->make_text($number_of_rights . $publication_conditions  . $right_element->findnodes('//right/oa_agreement')->item(0)->textContent);	

			#Table rights
			# Create table
			my $table = $session->make_element( "table" );
			# Row with headings
			my $oa_row = $session->make_element( "tr" );
			#User message
			#my $message = $right_element->findnodes('//right/message')->item(0)->textContent;
			my $p_message = $session->make_element( "h4",  class=>"oamsg" );
			$p_message->appendChild( $session->make_text( $message ) );
			my $cell_msg = $session->make_element( "td", class=>"ezboa_cell_message");
			$cell_msg->appendChild( $p_message );
			#State image
			#my $img_oa_available = $session->make_element( "img", src=>"/images/oa_rights_available.png", class=>"oa_available" );
			#$cell_msg->appendChild( $img_oa_available );
			#Embargo
			my $embargo = $right_element->findnodes('//right/oa_embargo_months')->item(0)->textContent;
			my $heading_embargo = $session->make_element( "h4" );
			$heading_embargo->appendChild( $session->make_text( $self->html_phrase( "heading_embargo" ) . ": " . $embargo ) );	
			$cell_msg->appendChild( $heading_embargo );
				
			my $ezb_link_p = $session->make_element( "p" );
			my $ezb_link = $session->make_element( "a", href=>"http://ezb.ur.de/detail.phtml?bibid=" . $lib_id ."&lang=" . $lang . "&issn=" . $issn, target=>"_blank" );
			$ezb_link->appendChild($self->html_phrase("msg_ezb_journal_link"));
			$ezb_link_p->appendChild($ezb_link);
			$cell_msg->appendChild($ezb_link_p);

			#Heading version
			my $heading_version = $session->make_element( "h4" );
			$heading_version->appendChild( $self->html_phrase( "heading_versions" ) );
			$cell_msg->appendChild($heading_version);

			my $list = $session->make_element( "ul" );
			foreach my $cat ($right_element->findnodes('//right/oa_archivable_version')->item($index)) {
  				foreach my $node ($cat->findnodes('*')) {
					my $li_message = $session->make_element( "li" );
					#$li_message->appendChild( $session->make_element( "img", src=>"/images/greentick.gif", width=>'20', height=>'20') );
					$li_message->appendChild( $session->make_text( ' ' . $node->textContent ));
					$list->appendChild( $li_message );
  				}
			}
			#$cell_msg->appendChild($list);
			
			#my $heading_repo = $session->make_element( "h4" );
			#$heading_repo->appendChild( $self->html_phrase( "heading_repositories" ) );
			#$cell_msg->appendChild($heading_repo);

			#my $list = $session->make_element( "ul" );
			foreach my $cat ($right_element->findnodes('//right/oa_repositories')->item($index)) {
  				foreach my $node ($cat->findnodes('*')) {
					my $li_message = $session->make_element( "li", class=>$index );
					$li_message->appendChild($session->make_text( $node->textContent ));
					$list->appendChild( $li_message );
  				}
			}

			$cell_msg->appendChild($list);
			
			my $oa_remarks_cell = $session->make_element( "td", valign=>"top" );
			my $remarks_heading = '';
			my $remarks_de = '';
			my $remarks_en = '';
			if ($lang eq 'de'){
				$remarks_de = $right_element->findnodes('//right/remarks_de')->item($index)->textContent;
				$remarks_heading = "Bemerkung auf Deutsch:";

			if ($remarks_de eq ''){
				#$remarks_de = $right_element->findnodes('//right/remarks_en')->item($index)->textContent;
				#$remarks_heading = "Bemerkung auf Englisch";
			}
			if ($remarks_de ne ''){
				my $pkg_owner_heading = $session->make_element("h2");
				$pkg_owner_heading->appendChild($session->make_text($remarks_heading));
				my $pkg_owner_comment_p = $session->make_element("p");
				$pkg_owner_comment_p->appendChild($session->make_text($remarks_de));
				$oa_remarks_cell->appendChild($pkg_owner_heading);
				$oa_remarks_cell->appendChild($pkg_owner_comment_p);
			}
		} else {

			$remarks_heading = 'Comment:';
			$remarks_en = $right_element->findnodes('//right/remarks_en')->item($index)->textContent;
			if ($remarks_en eq ''){
				#$remarks_heading = "Comment in German:";
				#$remarks_en = $right_element->findnodes('//right/remarks_de')->item($index)->textContent;
			}
			if ($remarks_en ne ''){
				my $pkg_owner_heading = $session->make_element("h2");
				$pkg_owner_heading->appendChild($session->make_text($remarks_heading));
				my $pkg_owner_comment_p = $session->make_element("p");
				$pkg_owner_comment_p->appendChild($session->make_text($remarks_en));
				$oa_remarks_cell->appendChild($pkg_owner_heading);
				$oa_remarks_cell->appendChild($pkg_owner_comment_p);
			}
		}

			#EZB logo
			#my $cell_logo = $session->make_element( "td", style=>"width: 20%;"  );
			#my $img_ezb = $session->make_element( "img", src=>$self->html_phrase( "logo_path" ), class=>"ezb_logo");
			#$cell_logo->appendChild( $img_ezb );
			$oa_row->appendChild( $cell_msg );

			if($remarks_de ne '' or $remarks_en ne ''){
				$oa_row->appendChild( $oa_remarks_cell );
			}


			$table->appendChild( $oa_row );			
			$wrapper_div->appendChild( $table );			


			if($number_of_entries eq $index+1){
				my $bar_hr = $session->make_element("hr");
				$wrapper_div->appendChild($bar_hr);
				my $ezb_info = $session->make_element("p", class=>"infotext");
				$ezb_info->appendChild($self->html_phrase("ezb_dfg_info"));
				$wrapper_div->appendChild($ezb_info);
			} else {
				my $bar_hr = $session->make_element("hr");
				$wrapper_div->appendChild($bar_hr);
			}

		} 
		
	
		#No OA rights available 
		if (($right_element->findnodes('//right/state')->item(0)->textContent + 0) >= 2 ) {	
			# Create table
			my $table = $session->make_element( "table" );
			# Row with headings
			my $oa_row = $session->make_element( "tr" );

			my $info_p = $session->make_element("p");

			# status codes >= 5 for user input errors
			if (($right_element->findnodes('//right/state')->item(0)->textContent + 0) >= 5){
				#State image
				#my $img_oa_not_available = $session->make_element( "img", src=>"/images/oa_rights_not_available.svg", class=>"oa_not_available" );
				#$cell_msg->appendChild( $img_oa_not_available );
				$info_p->appendChild( $self->html_phrase("msg_error_note" ));
			} else {
				$info_p->appendChild( $self->html_phrase("msg_no_rights_note" ));
			}

			#$table->appendChild( $oa_row );
			$wrapper_div->appendChild( $table );	

			# issn and doi a given but either are wrong 
			if ($issn ne '' && ($right_element->findnodes('//right/state')->item(0)->textContent + 0) ne 5 ){
				my $ezb_link_p = $session->make_element( "p" );
				my $ezb_link = $session->make_element( "a", href=>"http://ezb.ur.de/detail.phtml?bibid=" . $lib_id ."&lang=" . $lang . "&issn=" . $issn, target=>"_blank" );
				$ezb_link->appendChild($self->html_phrase("msg_ezb_journal_link"));
				$ezb_link_p->appendChild($ezb_link);
				$wrapper_div->appendChild($ezb_link_p);
			}
			$wrapper_div->appendChild($info_p);
			}	
		$index++;

	}

		$div_ep_toolbox_content->appendChild( $wrapper_div );

		return $ezboa;
}

sub append_legalinfo{


	my( $self ) = @_;

	my $session = $self->{session};

	my $ezboa = $session->make_doc_fragment;
	
	my $div_ep_toolbox = $session->make_element( "div", class=>"ep_toolbox" );
	my $div_ep_toolbox_title = $session->make_element( "div", class=>"ep_toolbox_title" );

	my $div_ep_toolbox_content = $session->make_element( "div", class=>"ep_toolbox_content" );
        $div_ep_toolbox_content->appendChild( $div_ep_toolbox_title );
	$div_ep_toolbox->appendChild( $div_ep_toolbox_content );
	$ezboa->appendChild( $div_ep_toolbox );

	my $wrapper_div = $session->make_element("div", id=>"ezboa_legal");
	
	my $link = $session->render_link( $self->html_phrase("ezb_legal_info_url") );
	$link->appendChild( $self->html_phrase( "ezb_legal_info_link" )  );
	$wrapper_div->appendChild( $link );	

	my $legal_msg = $session->make_element( "p" );
	$legal_msg->appendChild( $session->make_text( $self->html_phrase( "ezb_legal_info" ) ) );
	$wrapper_div->appendChild( $legal_msg );

	$div_ep_toolbox_content->appendChild( $wrapper_div );
	return $ezboa;

}

sub render_content
{
        my( $self, $surround ) = @_;

        my $session = $self->{session};
        #my $f = $session->make_doc_fragment;

        my $html = $session->make_doc_fragment;

	if ($self->{session}->get_repository->get_conf("ezb_show_ezb") == 1){
		$html->appendChild( $self->check_ezboa );
	}

	if ($self->{session}->get_repository->get_conf("ezb_show_legal_info") == 1){
		#$html->appendChild( $self->append_legalinfo );
	}
	
        return $html;
}



1;