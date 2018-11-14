=head1 NAME

EPrints::Plugin::InputForm::Component::Romeo

=cut

package EPrints::Plugin::InputForm::Component::Romeo;

use EPrints::Plugin::InputForm::Component;
@ISA = ( "EPrints::Plugin::InputForm::Component" );

use strict;
use Data::Dumper;
use HTML::StripTags qw(strip_tags);

sub new
{
	my( $class, %opts ) = @_;
	my $self = $class->SUPER::new( %opts );	
	$self->{name} = "Romeo";
	$self->{visible} = "all";
	# a list of documents to unroll when rendering, 
	# this is used by the POST processing, not GET
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

sub check_romeo 
{
	my( $self ) = @_;
	my $session = $self->{session};

	# Debug mode
	my $debug =  $session->get_repository->get_conf("ezb_debug");
	my $romeo = $session->make_doc_fragment;
	#my @issns = $self->{dataobj}->get_value( "issn" );
	my $issn = $self->{dataobj}->get_value( "issn" );
	#my $issn = $issns[0][0];
		#Get title
		my $title = $self->{dataobj}->get_value("title");
	
	my $ezb_service_adress = $session->get_repository->get_conf("ezb_service_adress");
	if( !defined $issn )
	{
		
		# EZB eprints service adress
		#my $ezb_service_adress = $session->get_repository->get_conf("ezb_service_adress");
	
		my $url = '';
		$issn = 'romeo_issn_undefined';

		#Get title
		my $title = $self->{dataobj}->get_value("title");

		if ($title ne ''){
			$url = $ezb_service_adress . "?title=" . $title . "&format=application/xml";
		}	

		# Get DOI
		#my @dois = $self->{dataobj}->get_value("id_number");
		my $doi = $self->{dataobj}->get_value("id_number");
		#my $doi = $dois[0][0]{name};

		if ($doi ne ''){
			$url = $ezb_service_adress . "?doi=" . $doi . "&format=application/xml";
		}			

#=begin comment	
		if ((($doi ne '') || ($title ne '')) && ($url ne '')){
			my $xml = EPrints::XML::parse_url( $url );
			my $state = $xml->findnodes('//oa/right/state')->item(0)->textContent . 0;
				if ($state eq 1){
					$issn = $xml->getElementsByTagName( "issn" )->item(0)->textContent;
				} else {
					$issn = 'romeo_issn_undefined';
				}
		} else {
			$issn = 'romeo_issn_undefined';
		}
#=cut
	}

	   # check for ISSN-Errors caused by wrong user input e.g. 'jjjj-kkkk'
		my $url = $ezb_service_adress . "?issn=" . $issn . "&format=application/xml";
                my $xml = EPrints::XML::parse_url( $url );
                my $state = $xml->findnodes('//oa/right/state')->item(0)->textContent . 0;
                if ($state eq 8 || $state eq 9){
                      $issn = 'romeo_issn_undefined';
                }


	my $div_ep_toolbox = $session->make_element( "div", class=>"ep_toolbox" );
	my $div_ep_toolbox_content = $session->make_element( "div", class=>"ep_toolbox_content" );
        $div_ep_toolbox->appendChild( $div_ep_toolbox_content );
        $romeo->appendChild( $div_ep_toolbox );
	#my $div_ep_toolbox_content = $session->make_element( "div", class=>"ep_toolbox_content" );
	#my $url = URI->new("http://www.sherpa.ac.uk/romeo/api29.php");
	my $apikey = $session->get_repository->get_conf("sherpa_service_key");
	$url = URI->new($session->get_repository->get_conf("sherpa_service_adress"));

	if( $issn eq 'romeo_issn_undefined' and $title ne '' )
	 {
			$url->query_form( $url->query_form, jtitle => $title, versions => 'all', ak => $apikey );
	} else {
        $url->query_form( $url->query_form, issn => $issn, versions => 'all', ak => $apikey );	
	}

	$xml = EPrints::XML::parse_url( $url );        
        my $root = $xml->documentElement;
	if ($debug){
		my $div_left = $session->make_element( "div", id=>"romeo_left" );
		my $heading_debug = $session->make_element( "h4" );
		$heading_debug->appendChild( $session->make_text( "-------- DEBUG INFORMATION --------" ) );
		$div_left->appendChild( $heading_debug );

        	$div_ep_toolbox_content->appendChild( $div_left );

		my $romeo_msg = $session->make_element( "h4" );
		$romeo_msg->appendChild( $session->make_text( "RoMEO message: " ) );
		$div_left->appendChild( $romeo_msg );

		my $xml_error_msg_p = $session->make_element( "p" );
		my $xml_error_msg = $xml->getElementsByTagName('message')->item(0)->textContent;
		$xml_error_msg_p->appendChild( $session->make_text($xml_error_msg) ); 
		$div_left->appendChild($xml_error_msg_p);

		my $heading_link = $session->make_element( "h4" );
		$heading_link->appendChild( $session->make_text( "REST Link: " ) );
		$div_left->appendChild( $heading_link );	

		my $api_link = $session->make_element( "a", href=>$url, target=>"_blank" );
		$api_link->appendChild($session->make_text($url));
		my $api_link_p = $session->make_element( "p" );
		$api_link_p->appendChild($api_link);
		$div_left->appendChild($api_link_p);

		my $heading_xml = $session->make_element( "h4" );
		$heading_xml->appendChild( $session->make_text( "XML Output: " ) );
		$div_left->appendChild( $heading_xml );	

		my $xml_string = $session->make_element( "p" );
		$xml_string->appendChild($session->make_text( $xml ));
		$div_left->appendChild($xml_string);
 
		my $heading_debug_end = $session->make_element( "h4" );
		$heading_debug_end->appendChild( $session->make_text( "-------- END DEBUG INFORMATION --------" ) );
		$div_left->appendChild( $heading_debug_end );	
	}

	#if RoMEO response doesn't contain any journals
	my $num_publishers = scalar(@{$xml->findnodes('//romeoapi/journals/journal')});
	if ($num_publishers eq 0){
		$issn = 'romeo_issn_undefined';
	}

	#if( $issn eq 'romeo_issn_undefined' and $title eq '' )
	if( $issn eq 'romeo_issn_undefined')
        {

		# Create table
		my $table = $session->make_element( "table" );
		# Row with headings
		my $oa_row = $session->make_element( "tr" );

		#User message
		my $p_message = $session->make_element( "h2",  class=>"oamsg" );
		$p_message->appendChild( $self->html_phrase( "msg_no_rights_available" ) );
		my $cell_msg = $session->make_element( "td", class=>"oa_cell_msg");
		$cell_msg->appendChild( $p_message );
		#State image
		my $img_oa_available = $session->make_element( "img", src=>"/images/oa_rights_not_available.svg", class=>"oa_not_available" );
		$cell_msg->appendChild( $img_oa_available );
				
		#EZB logo
		my $cell_logo = $session->make_element( "td", class=>"sherpa_logo_cell");
		my $logo_sherpa = $session->make_element( "img", src=>"/images/oa_sherpa_romeo.png", class=>"sherpa_logo");
		$cell_logo->appendChild( $logo_sherpa );
		$oa_row->appendChild( $cell_msg );
		$oa_row->appendChild( $cell_logo );
		$table->appendChild( $oa_row );	
		
		$div_ep_toolbox_content->appendChild($table);
		
		my $xml_error_msg_p = $session->make_element( "p" );
		my $xml_error_msg = $xml->getElementsByTagName('message')->item(0)->textContent;
		if ($title ne ''){
			$xml_error_msg = '"' . $title . '"' . $self->html_phrase( "title_not_found" );
		}
		$xml_error_msg_p->appendChild( $session->make_text($xml_error_msg) ); 
		$div_ep_toolbox_content->appendChild($xml_error_msg_p);
		
        	$div_ep_toolbox->appendChild( $div_ep_toolbox_content );
        	$romeo->appendChild( $div_ep_toolbox );
            return $romeo;
        } 

	foreach my $publisher ($xml->getElementsByTagName( "publisher" ) ) {

		my $div_left = $session->make_element( "div", id=>"romeo_left" );
        	$div_ep_toolbox_content->appendChild( $div_left );

		my $div_right = $session->make_element( "div", id=>"romeo_right" );
        	$div_ep_toolbox_content->appendChild( $div_right );
		
     	
		my $pubName = $publisher->getElementsByTagName( "name" )->item(0)->textContent;
            	my $pubAlias = $publisher->getElementsByTagName( "alias" )->item(0)->textContent;
            	my $pubURL = $publisher->getElementsByTagName( "homeurl" )->item(0)->textContent;
            	my $pubColor = $publisher->getElementsByTagName( "romeocolour" )->item(0)->textContent;
            	my $pubPreArchiving = $publisher->getElementsByTagName( "prearchiving" )->item(0)->textContent;
            	my $pubPostArchiving = $publisher->getElementsByTagName( "postarchiving" )->item(0)->textContent;
		my $pubPDFArchiving = $publisher->getElementsByTagName( "pdfarchiving" )->item(0)->textContent;

		my $romeo_about = $session->make_element( "p", class=>"hide" );
                $romeo_about->appendChild($self->html_phrase( "romeo_about" ));
		$div_left->appendChild($romeo_about);

		my $div_left_pubname = $session->make_element( "h1", class=>"romeo " . $pubColor );		
		$div_left_pubname->appendChild($session->make_text( $pubName." ".$pubAlias ));

		my $romeoUrl = $session->render_link( $session->get_repository->get_conf("sherpa_issn_search_adress")."?issn=".$issn, "_blank" );
		$romeoUrl->appendChild($self->html_phrase( "publisher_info_at_romeo" ) );

		my $pubUrl = $session->render_link( $pubURL, "_blank" );
		$pubUrl->appendChild($self->html_phrase( "publisher_info_website" ) );

		my $div_left_romeo_url = $session->make_element( "p" );		
		$div_left_romeo_url->appendChild( $romeoUrl );
		
		my $div_left_pub_url = $session->make_element( "p" );		
		$div_left_pub_url->appendChild( $pubUrl );

		$div_left->appendChild( $div_left_pubname );
		$div_left->appendChild( $div_left_romeo_url );
		$div_left->appendChild( $div_left_pub_url );

		my $pub_list = $session->make_element( "ul", class=>"romeo_results" );

		if ($pubPreArchiving eq 'can') {
			my $li_message = $session->make_element( "li" );
			$li_message->appendChild($self->html_phrase( "romeo_preprint_can" ));
			$pub_list->appendChild( $li_message );		
		}
		if ($pubPreArchiving eq 'cannot') {
			my $li_message = $session->make_element( "li" );
			$li_message->appendChild($self->html_phrase( "romeo_preprint_cannot" ));
			$pub_list->appendChild( $li_message );
                }
		if ($pubPreArchiving eq 'unclear' || $pubPreArchiving eq 'unknown') {
			#$div_right->appendChild($session->make_element( "br" ));
			#$div_right->appendChild($self->html_phrase( "romeo_preprint_unclear" ));
			#$div_right->appendChild($session->make_element( "br" ));
			my $li_message = $session->make_element( "li" );
			$li_message->appendChild($self->html_phrase( "romeo_preprint_unclear" ));
			$pub_list->appendChild( $li_message );

                }
		if ($pubPreArchiving eq 'restricted') {
                        $div_right->appendChild($session->make_element( "br" ));
                        $div_right->appendChild($self->html_phrase( "romeo_preprint_restricted" ));

			my $pub_pre_restrictions = $session->make_element( "ul" );

                        foreach my $pubPreRestriction ( $publisher->getElementsByTagName( "prerestriction" ) ) {

                                my $pubPreRestrictionText = $session->make_element( "li" );
                                $pubPreRestrictionText->appendChild($session->make_text(strip_tags( $pubPreRestriction->textContent )));
                                $pub_pre_restrictions->appendChild($pubPreRestrictionText);

                        }
                        $div_right->appendChild($pub_pre_restrictions);
                }

		if ($pubPostArchiving eq 'can') {
			my $li_message = $session->make_element( "li" );
			$li_message->appendChild($self->html_phrase( "romeo_postprint_can" ));
			$pub_list->appendChild( $li_message );

                }
                if ($pubPostArchiving eq 'cannot') {
			my $li_message = $session->make_element( "li" );
			$li_message->appendChild($self->html_phrase( "romeo_postprint_cannot" ));
			$pub_list->appendChild( $li_message );
                }
                if ($pubPostArchiving eq 'unclear' || $pubPreArchiving eq 'unknown') {
                        $div_right->appendChild($session->make_element( "br" ));
                        $div_right->appendChild($self->html_phrase( "romeo_notice" ));
			$div_right->appendChild($session->make_element( "br" ));
                }
                if ($pubPostArchiving eq 'restricted') {
                        $div_right->appendChild($session->make_element( "br" ));
                        $div_right->appendChild($self->html_phrase( "romeo_postprint_restricted" ));

			my $pub_post_restrictions = $session->make_element( "ul" );

                	foreach my $pubPostRestriction ( $publisher->getElementsByTagName( "postrestriction" ) ) {

                        	my $pubPostRestrictionText = $session->make_element( "li" );
                        	$pubPostRestrictionText->appendChild($session->make_text(strip_tags( $pubPostRestriction->textContent )));
                        	$pub_post_restrictions->appendChild($pubPostRestrictionText);

                	}
                	$div_right->appendChild($pub_post_restrictions);
                }

		if ($pubPDFArchiving eq 'can') {
			my $li_message = $session->make_element( "li" );
			$li_message->appendChild($self->html_phrase( "romeo_pdf_can" ));
			$pub_list->appendChild( $li_message );

                }
                if ($pubPDFArchiving eq 'cannot') {
			my $li_message = $session->make_element( "li" );
			$li_message->appendChild($self->html_phrase( "romeo_pdf_cannot" ));
			$pub_list->appendChild( $li_message );
                }

		# Create table
			my $table = $session->make_element( "table" );
			# Row with headings
			my $oa_row = $session->make_element( "tr" );

				#User message
				my $p_message = $session->make_element( "h2",  class=>"oamsg" );
				$p_message->appendChild( $self->html_phrase( "oamsg" ) );
				my $cell_msg = $session->make_element( "td", class=>"oa_cell_msg");
				$cell_msg->appendChild( $p_message );
				#State image
				#my $cell_img = $session->make_element( "td" );
				my $img_oa_available = $session->make_element( "img", src=>"/images/oa_rights_available.png", class=>"oa_available" );
				$cell_msg->appendChild( $img_oa_available );
	
				#EZB logo
				my $cell_logo = $session->make_element( "td", class=>"sherpa_logo_cell" );
				my $logo_sherpa = $session->make_element( "img", src=>"/images/oa_sherpa_romeo.png", class=>"sherpa_logo");
				$cell_logo->appendChild( $logo_sherpa );
				$oa_row->appendChild( $cell_msg );
				#$oa_row->appendChild( $cell_img );
				$oa_row->appendChild( $cell_logo );

			$table->appendChild( $oa_row );	
			# Create table
			my $table2 = $session->make_element( "table" );
			# Row with headings
			my $heading_row = $session->make_element( "tr" );
			my $result_row = $session->make_element( "tr" );
			#Results
				my $heading_cell = $session->make_element( "th"  );
				my $p_heading = $session->make_element( "p" );
				$p_heading->appendChild($self->html_phrase( "heading_versions" ));
				$heading_cell->appendChild($p_heading);
				$heading_row->appendChild($heading_cell);
				
				my $heading_cell2 = $session->make_element( "th"  );
				my $p_heading2 = $session->make_element( "p" );
				$p_heading2->appendChild($self->html_phrase( "romeo_colour" ));
				$heading_cell2->appendChild($p_heading2);
				$heading_row->appendChild($heading_cell2);

				my $heading_cell3 = $session->make_element( "th"  );
				my $p_heading3 = $session->make_element( "p" );
				$p_heading3->appendChild($self->html_phrase( "publisher_info" ));
				$heading_cell3->appendChild($p_heading3);
				$heading_row->appendChild($heading_cell3);

				my $result_cell = $session->make_element( "td"  );
				#my $p_heading = $session->make_element( "p" );
				#$p_heading->appendChild($session->make_text( "Welche Versionen des Artikels dürfen Sie frei veröffentlichen?" ));
				$result_cell->appendChild($pub_list);
				$result_row->appendChild($result_cell);
				
				my $result_cell2 = $session->make_element( "td"  );
				my $p_color = $session->make_element( "h2", style=>"color: " . $pubColor . ";" );
				$p_color->appendChild($session->make_text( $pubColor ));
				$result_cell2->appendChild($p_color);
				$result_row->appendChild($result_cell2);

				my $result_cell3 = $session->make_element( "td"  );
				#my $p_heading2 = $session->make_element( "p" );
				#$p_heading2->appendChild($session->make_text( "Romeo-Farbe" ));
				my $pub_info_list = $session->make_element( "ul" );
				my $pub_info_li1 = $session->make_element( "li" );
				$pub_info_li1->appendChild( $pubUrl );
				my $pub_info_li2 = $session->make_element( "li" );
				$pub_info_li2->appendChild( $romeoUrl );
				$pub_info_list->appendChild( $pub_info_li1  );	
				$pub_info_list->appendChild( $pub_info_li2  );
				$result_cell3->appendChild($pub_info_list);
				$result_row->appendChild($result_cell3);

			$table2->appendChild( $heading_row );
			$table2->appendChild( $result_row );

		$div_right->appendChild($table);
		$div_right->appendChild($table2);

		my $div_right_pub_conditions_title = $session->make_element( "h2", class=>"romeo_title" );
		$div_right_pub_conditions_title->appendChild($self->html_phrase( "publishing_conditions" ) );
		$div_right->appendChild($div_right_pub_conditions_title);
		my $div_right_pub_conditions = $session->make_element( "ul" );

		foreach my $pubCondition ( $publisher->getElementsByTagName( "condition" ) ) {
			
			my $div_right_pub_condition = $session->make_element( "li" );
			$div_right_pub_condition->appendChild( $session->make_text(strip_tags( $pubCondition->textContent )));
			#$div_right_pub_condition->appendChild( $session->make_text($pubCondition->textContent ));
			$div_right_pub_conditions->appendChild($div_right_pub_condition);
		}
		
		$div_right->appendChild($div_right_pub_conditions);
		my $div_right_pub_cplinks_title = $session->make_element( "h2", class=>"romeo_title" );
                $div_right_pub_cplinks_title->appendChild($self->html_phrase( "publishing_cp_right_links" ) );
                $div_right->appendChild($div_right_pub_cplinks_title);
                my $div_right_pub_cplinks = $session->make_element( "ul" );

                foreach my $pubCplink ( $publisher->getElementsByTagName( "copyrightlink" ) ) {
                        my $div_right_pub_cplink = $session->make_element( "li" );
                        my $div_right_pub_cplink_a = $session->render_link ( $pubCplink->getElementsByTagName( "copyrightlinkurl" )->item(0)->textContent, "_blank" );
                	$div_right_pub_cplink_a->appendChild($session->make_text( strip_tags( $pubCplink->getElementsByTagName( "copyrightlinktext" )->item(0)->textContent )));
			$div_right_pub_cplink->appendChild($div_right_pub_cplink_a);
                        $div_right_pub_cplinks->appendChild($div_right_pub_cplink);
                }

                $div_right->appendChild($div_right_pub_cplinks);
		my $div_clear = $session->make_element( "div", style=>"clear: both" );
        	$div_ep_toolbox_content->appendChild( $div_clear );

	}

	return $romeo;
}


sub render_content
{
        my( $self, $surround ) = @_;
        my $session = $self->{session};
	my $html = $session->make_doc_fragment;
	if ($session->get_repository->get_conf("ezb_show_sherparomeo") == 1){
        	$html->appendChild( $self->check_romeo );
	}

	if ($session->get_repository->get_conf("ezb_show_sherparomeo") == 0){
        	#$html->appendChild( $self->check_romeo );
	}

        return $html;
}

1;
 
=head1 COPYRIGHT

=for COPYRIGHT BEGIN

SHERPA RoMEO check plugin for Eprints
(C) 2012 - Alen Vodopijevec <alen@irb.hr>

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints L<http://www.eprints.org/>.

EPrints is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

EPrints is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints.  If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END
