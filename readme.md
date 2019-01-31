Image:
- PHP
  - php ^7.3.#
  - composer 1.8.3
- PHP-ext
  - intl
  - postgres
  - soap
  - gd
  - bz2
  - redis 4.2.0
  - bcmath
  - xsl
  - zip
- Other
  - bash
  - nano
  - openssh
  - git

- production
  - `docker build --rm -t efureev/php73-prod:latest .`
  - `docker run -d -p 9073:9000 -v /Volumes/Data/www:/www:delegated --link redis:redis --link fake_sudis:fake_sudis --name php73-prod efureev/php73-prod` # общий php7.3
- development
  - `docker build --rm -t efureev/php73-dev:latest ./dev`
  - `docker run -d -p 32780:9000 -v /Volumes/Data/www:/www --name php73-dev efureev/php73-dev`