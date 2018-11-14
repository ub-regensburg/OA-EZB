# OA-EZB: An EPrints plug-in for integrating OA rights from alliance and national licenses into institutional repositories.
#### English
Open Access rights (OA rights) from alliance and national licences, which are stored in the [Elektronischen Zeitschriftenbibliothek (EZB)](https://ezb.ur.de/), can now be integrated into institutional repositories. This is now possible with OA-EZB, a plug-in specially developed for the repository software EPrints, which accesses the EZB's new OA interface services.

This plug-in was developed as part of the DFG project [„OA-EZB: Open Access Services of the Electronic Journals Library (DFG project)“](https://www.uni-regensburg.de/library/projects/oa-ezb/index.html) at University of Regensburg Library. It consists of three modules that can be configured separately from each other. The first module accesses the OA interfaces of the EZB and displays the information on deposited secondary publication rights, e.g. for alliance licenses, in an overview. The second module retrieves publishers' OA policies in [SHERPA/RoMEO](http://www.sherpa.ac.uk/romeo/index.php). In the third module a reference to the [German secondary publication law according to copyright law](https://www.gesetze-im-internet.de/urhg/__38.html) is issued.

In the front end of the EPrints repository, the retrieved data of all modules appear at a previously defined point, for example before uploading an article.
Authors thus receive all the necessary information in an overview even before their research results are uploaded, which provides uncomplicated information about the possibilities of publishing in Open Access. This is intended to promote the use of the green path.

On the technical side, the existing [EPrints plug-in for SHERPA/RoMEo](http://files.eprints.org/799/) (developped by Alen Vodopijevec at Ruđer Bošković Institute, Zagreb) was updated and access to the new EZB interface services implemented. OA-EZB will be developed for EPrints version 3.3.16 and will be made available for free use under the GPL license on GitHub upon completion. Its operation requires registration for API accesses to SHERPA/RoMEO and the EZB.

For illustration purposes, a publicly accessible test environment has been set up, which can be accessed at https://oa-ezb.uni-regensburg.de . Instructions can be found on the start page. The possibility of changing the EZB Institution ID (ECB-BIBID) in the test environment demonstrates the great advantage of accessing the OA rights stored in the ECB, as the information is immediately issued to users on an institution-specific basis. After its completion, OA-EZB will become an integral part of the [University of Regensburg publication server](https://epub.uni-regensburg.de/).

#### Deutsch
Open-Access-Rechte (OA-Rechte) aus Allianz-und Nationallizenzen, die in der [Elektronischen Zeitschriftenbibliothek (EZB)](https://ezb.ur.de/) erfasst sind, lassen sich nun in institutionelle Repositorien einbinden. Dies gelingt nun mit OA-EZB, einem eigens für die Repositoriensoftware EPrints entwickelten Plug-in, das auf die neuen OA-Schnittstellendienste der EZB zugreift. 

Dieses Plugin wurde im Rahmen des DFG-Projektes [„OA-EZB: Open-Access-Services der Elektronischen Zeitschriftenbibliothek (EZB)“](https://www.uni-regensburg.de/bibliothek/projekte/oa-ezb/index.html) an der Universitätsbibliothek Regensburg entwickelt. Es besteht aus drei Modulen, die sich getrennt voneinander konfigurieren lassen. Das erste Modul greift auf die OA-Schnittstellen der EZB zu und gibt die Informationen über hinterlegte Zweitveröffentlichungsrechte, z.B. für Allianz-Lizenzen, in einer Übersicht aus. Das zweite Modul ruft verlagsseitige OA-Policies in [SHERPA/RoMEO](http://www.sherpa.ac.uk/romeo/index.php) ab. Im dritten Modul wird ein Hinweis auf das deutsche [Zweitveröffentlichungsrecht gemäß Urheberrechtsgesetz](https://www.gesetze-im-internet.de/urhg/__38.html) ausgegeben.

Im Frontend des EPrints-Repositoriums erscheinen die abgerufenen Daten aller Module an einer zuvor definierten Stelle, beispielsweise vor dem Hochladen eines Artikels.

Somit erhalten Autoren bereits vor dem Hochladen ihrer Forschungsergebnisse alle erforderlichen Informationen in einer Übersicht, die unkompliziert über die Möglichkeiten zur Veröffentlichung in Open Access aufklärt. Damit soll die Nutzung des grünen Weges gefördert werden.
 
Auf technischer Seite wurde das existierende [EPrints-Plug-in für SHERPA/RoMEo](http://files.eprints.org/799/) (entwickelt von Alen Vodopijevec am Ruđer Bošković Institut, Zagreb) aktualisiert und der Zugriff auf die neuen EZB-Schnittstellendienste implementiert. Die Entwicklung von OA-EZB erfolgt für EPrints der Version 3.3.16 und wird bei Abschluss unter der GPL-Lizenz auf GitHub zur freien Nutzung bereitgestellt. Für seinen Betrieb ist eine Registrierung für die API-Zugänge bei SHERPA/RoMEO und bei der EZB notwendig.

Zur Veranschaulichung wurde eine öffentlich zugängliche Testumgebung eingerichtet, die unter https://oa-ezb.uni-regensburg.de abgerufen werden kann. Eine Anleitung befindet sich auf der Startseite. Durch den in der Testumgebung möglichen Wechsel der EZB- Institutions-ID (EZB-BIBID), zeigt sich der große Vorteil, den der Zugriff auf die in der EZB hinterlegten OA-Rechte bietet, da die Informationen sofort institutionsspezifisch für die Nutzer ausgegeben werden. Nach seiner Fertigstellung wird OA-EZB ein fester Bestandteil des [Publikationsservers der Universität Regensburg](https://epub.uni-regensburg.de/).

## Requirements

The following requirements must be met for proper operation of the plug-in:

- Internet access
- Valid SHERPA/RoMEO Api-Key ([further details](http://www.sherpa.ac.uk/romeo/apiregistry.php))
- Your institution is participating in the corresponding alliance/national licenses

## INSTALLATION INSTRUCTIONS

**WARNING! Backup everything first, we cannot be responsible in case of failure**

1. Copy *.rm files to component plugin folder (usually EPRINTS_ROOT/perl_lib/ARCHIVE_ID/Plugin/InputForm/Component)
2. Edit config file z_ezboa.pl and copy to EPRINTS_ROOT/archives/ARCHIVE_ID/cfg/cfg.d
	- set your EZB institution-id (if the institution-id isn't set the OA-EZB API tries to determine it via IP-adress)
	- set your SHERPA/RoMEO api key
	- choose the plug-in modules to be displayed
3. Create plugin phrases inside your phrases folder (usually EPRINTS_ROOT/archives/ARCHIVE_ID/cfg/lang/en/phrases for English phrases, see model files included)
4. Edit workflow (EPRINTS_ROOT/archives/ARCHIVE_ID/cfg/workflows/eprint/default.xml)

```
<flow>
	<stage ref="type"/>
	<stage ref="files"/>
	<stage ref="core"/>
	<epc:if test="type = 'article'">
		<stage ref="policies"/>
	</epc:if>
	<stage ref="subjects"/>
</flow>
<stage name="policies">
	<component type="XHTML" surround="None">
		<h1>
			<epc:phrase ref="ezboa_main_heading" />
		</h1>
	</component>
	<epc:if test="$config{ezb_show_ezb} = 1">
		<component type="XHTML" surround="None">
			<h2>
				<epc:phrase ref="ezboa_sub_heading1" />
			</h2>
		</component>
		<component type="Ezboa" collapse="no" surround="None"></component>
	</epc:if>
	<epc:if test="$config{ezb_show_sherparomeo} = 1">
		<component type="XHTML" surround="None">
			<h2>
				<epc:phrase ref="ezboa_sub_heading2" />
			</h2>
		</component>
		<component type="Romeo" collapse="no" surround="None"></component>
	</epc:if>
	<epc:if test="$config{ezb_show_legal_info} = 1">
		<component type="XHTML" surround="None">
			<h2>
				<epc:phrase ref="ezboa_sub_heading3" />
			</h2>
		</component>
		<component type="XHTML" surround="None">
			<epc:phrase ref="Plugin/InputForm/Component/Ezboa:ezb_legal_info" />
		</component>
	</epc:if>
	<epc:if test="$config{ezb_show_disclaimer} = 1">
		<component type="XHTML" surround="None">
			<epc:phrase ref="Plugin/InputForm/Component/Ezboa:ezb_disclaimer_body" />
		</component>
	</epc:if>
	<component type="XHTML" surround="None">
		<hr />
	</component>
</stage>

```

  - we changed workflow so that users need to input ISSN first so in the next step we can check Romeo for that Journal
  - plugin is shown only for articles

5. check if required perl extensions are installed

```
sudo apt-get install build-essential

cpan HTML::StripTags

./bin/epadmin reload your_eprints_repository
```

6. Apply CSS styling. Copy *.css files to EPRINTS_ROOT/archives/ARCHIVE_ID/cfg/static/style/auto
7. Copy image files to images folder (usually EPRINTS_ROOT/archives/ARCHIVE_ID/cfg/static/images/ ).
8. restart Apache and test ...

```
# /sbin/service httpd restart
```

```
# /etc/init.d/apache2 restart
```

# Privacy
[Data protection policy for Universität Regensburg's websites and web applications](https://www.uni-regensburg.de/privacy/index.html)

# Support

The EZB and the extension for the administration of national and alliance licenses were developed at the University Library of Regensburg. The software EPrints 3.3.16, developed at the University of Southampton, is freely available under GPL 3.0. The plug-in OA-EZB was programmed at the University Library of Regensburg.

technical assistence / feedback

technik.ezb@ur.de

Dr. Gernot Deinzer (Open-Access-Beauftragter)

+49 941 943-2759

gernot.deinzer@bibliothek.uni-regensburg.de

# License
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Further Reading
- [OA rights in alliance and national licenses](https://www.nationallizenzen.de/open-access)
- [University of Regensburg Publication Server](https://epub.uni-regensburg.de/)
- [OA-EZB: Open Access Services of the Electronic Journals Library (DFG project)](https://www.uni-regensburg.de/library/projects/oa-ezb/index.html)
- [SHERPA/RoMEO EPrints plug-in](http://files.eprints.org/799/)

