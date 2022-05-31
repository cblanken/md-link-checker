# md-link-checker
### Usage
```console
$ ./md-link-checker.sh
Usage: ./md-link-checker.sh <file.md>

$ ./md-link-checker.sh ./comptia/sec+/1-threats-attacks-and-vulns.md
Status  | Link
---------------
200     | https://oasis-open.github.io/cti-documentation/taxii/intro.html
200     | https://oasis-open.github.io/cti-documentation/stix/intro.html
200     | https://www.cve.org/
200     | https://attack.mitre.org/techniques/T1546/011/
200     | https://attack.mitre.org/
200     | https://en.wikipedia.org/wiki/MAC_flooding
200     | https://en.wikipedia.org/wiki/Time-of-check_to_time-of-use
200     | https://en.wikipedia.org/wiki/Wi-Fi_deauthentication_attack
200     | https://en.wikipedia.org/wiki/Domain_hijacking
200     | https://en.wikipedia.org/wiki/MAC_spoofing
200     | https://en.wikipedia.org/wiki/ARP_spoofing
200     | https://nvd.nist.gov/vuln-metrics/cvss/v3-calculator
200     | https://en.wikipedia.org/wiki/Denial-of-service_attack#Distributed_DoS_attack
200     | https://nordvpn.com/blog/bluebugging/
200     | https://en.wikipedia.org/wiki/Denial-of-service_attack
200     | https://nordvpn.com/blog/bluejacking/
200     | https://nvd.nist.gov/
200     | https://en.wikipedia.org/wiki/Near-field_communication
200     | https://owasp.org/www-community/vulnerabilities/Buffer_Overflow
200     | https://www.malwarebytes.com/watering-hole-attack
200     | https://www.malwarebytes.com/pharming
200     | https://owasp.org/www-community/attacks/Man-in-the-browser_attack
200     | https://portswigger.net/web-security/cross-site-scripting
200     | https://portswigger.net/web-security/csrf
200     | https://portswigger.net/web-security/ssrf
200     | https://portswigger.net/web-security/sql-injection
200     | https://nordvpn.com/blog/bluesnarfing/

Checked 27 links in ./comptia/sec+/1-threats-attacks-and-vulns.md
```

- Run link checker on all markdown files in ~/notes/ and filtering files w/o links
```console
$ ls ~/notes/*.md | xargs -I {} ./md-link-checker.sh {} | grep -v "No links found"
```

