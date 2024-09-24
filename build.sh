#!/bin/bash

VERSION=`grep 'version=' VERSION | sed 's/version=//'`
LANGUAGES=(fr en pt es de it)

clean () {
  rm -r ${LANGUAGES[@]}
  rm *.tar.gz
}

archive () {
  for i in "${!LANGUAGES[@]}"
  do
    LANGUAGE=${LANGUAGES[$i]}
    cp -r i18n $LANGUAGE
    for j in "${!LANGUAGES[@]}"
    do
      if [ "${LANGUAGES[$j]}" != "$LANGUAGE" ]
      then
        find $LANGUAGE -name ${LANGUAGES[$j]}.json -exec rm '{}' \;
      fi
    done
    tar cfz $LANGUAGE-${VERSION}.tar.gz -C $LANGUAGE .
  done
  tar cfz all-${VERSION}.tar.gz ./i18n
}

publish () {
  case "$VERSION" in
    *SNAPSHOT) nexusRepository='snapshots' ;;
    *)         nexusRepository='releases' ;;
  esac
#  for i in "${!LANGUAGES[@]}"
#  do
#    LANGUAGE=${LANGUAGES[$i]}
    docker-compose run --rm maven mvn deploy:deploy-file -DgroupId=com.opendigitaleducation -DartifactId=ong-i18n -Dversion=$VERSION -Dpackaging=tar.gz -Dclassifier=fr -Dfile=fr-${VERSION}.tar.gz -Dfiles=en-${VERSION}.tar.gz,pt-${VERSION}.tar.gz,es-${VERSION}.tar.gz,de-${VERSION}.tar.gz,it-${VERSION}.tar.gz,all-${VERSION}.tar.gz -Dclassifiers=en,pt,es,de,it,all -Dtypes=tar.gz,tar.gz,tar.gz,tar.gz,tar.gz,tar.gz -DrepositoryId=maven-$nexusRepository -Durl=https://nexus-pic2.support-ent.fr/repository/maven-$nexusRepository/ -DNEXUS_USERNAME="$nexus_username" -DNEXUS_PASSWD="$nexus_password" -s settings.xml
#  done
}

for param in "$@"
do
  case $param in
    clean)
      clean
      ;;
    archive)
      archive
      ;;
    publish)
      publish
      ;;
    *)
      echo "Invalid argument : $param"
  esac
done

