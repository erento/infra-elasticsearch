#!/bin/sh
rm -rf tmp
mkdir -p tmp
wget "http://downloads.sourceforge.net/project/aoo-extensions/17102/21/dict-en.oxt?r=http%3A%2F%2Fextensions.openoffice.org%2Fen%2Fproject%2Fenglish-dictionaries-apache-openoffice&ts=1446585010&use_mirror=netassist" -O tmp/dict-en.zip
wget "http://downloads.sourceforge.net/project/aoo-extensions/1075/13/dict-de_de-frami_2013-12-06.oxt?r=http%3A%2F%2Fextensions.openoffice.org%2Fen%2Fproject%2Fgerman-de-de-frami-dictionaries&ts=1446585547&use_mirror=netassist" -O tmp/dict-de.zip

unzip tmp/dict-en.zip -d tmp/en
unzip tmp/dict-de.zip -d tmp/de

mkdir -p tmp/hunspell/de_DE
mkdir -p tmp/hunspell/en_GB

cp tmp/en/en_GB.aff tmp/hunspell/en_GB/en_GB.aff
cp tmp/en/en_GB.dic tmp/hunspell/en_GB/en_GB.dic
cp tmp/de/de_DE_frami/de_DE_frami.aff tmp/hunspell/de_DE/de_DE.aff
cp tmp/de/de_DE_frami/de_DE_frami.dic tmp/hunspell/de_DE/de_DE.dic

cp settings.yml tmp/hunspell/en_GB/
cp settings.yml tmp/hunspell/de_DE/

docker build -t gcr.io/erento-docker/search-els:latest .
