#!/usr/bin/env sh
set -e
DIR=~/Downloads
MIRROR=https://github.com/adoptium

# examples
# https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u312-b07/OpenJDK8U-jdk_x64_linux_hotspot_8u312b07.tar.gz
# https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u312-b07/OpenJDK8U-jre_x64_linux_hotspot_8u312b07.tar.gz

# https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u312-b07/OpenJDK8U-jdk_x64_windows_hotspot_8u312b07.zip
# https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u312-b07/OpenJDK8U-jre_x64_windows_hotspot_8u312b07.zip

# https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u312-b07/OpenJDK8U-jdk_aarch64_linux_hotspot_8u312b07.tar.gz
# https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u312-b07/OpenJDK8U-jre_aarch64_linux_hotspot_8u312b07.tar.gz

# https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u312-b07/OpenJDK8U-jdk_x64_mac_hotspot_8u312b07.tar.gz
# https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u312-b07/OpenJDK8U-jre_x64_mac_hotspot_8u312b07.tar.gz

# https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.13%2B8/OpenJDK11U-jdk_x64_linux_hotspot_11.0.13_8.tar.gz
# https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.13%2B8/OpenJDK11U-jre_x64_linux_hotspot_11.0.13_8.tar.gz

# https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.13%2B8/OpenJDK11U-jdk_x64_alpine-linux_hotspot_11.0.13_8.tar.gz
# https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.13%2B8/OpenJDK11U-jre_x64_linux_hotspot_11.0.13_8.tar.gz

# https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.1%2B12/OpenJDK17U-jdk_x64_alpine-linux_hotspot_17.0.1_12.tar.gz
# https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.1%2B12/OpenJDK17U-jre_x64_alpine-linux_hotspot_17.0.1_12.tar.gz

# https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.1%2B12/OpenJDK17U-jdk_x64_linux_hotspot_17.0.1_12.tar.gz
# https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.1%2B12/OpenJDK17U-jre_x64_linux_hotspot_17.0.1_12.tar.gz

dl()
{
    # jdk or jre
    local app=$1

    # 8, 11, 16
    local majorver=$2

    # 302, 0, 0
    local minorver=$3

    # N/A, 12, 2
    local patchver=$4

    # 08, 7, 7
    local bver=$5

    # linux
    local os=$6

    # x64
    local arch=$7

    # zip or tar.gz
    local archivetype=${8:-tar.gz}

    local platform="${os}_${arch}"

    if [ $majorver -ge 9 ]
    then
        local verstr=${majorver}.${minorver}.${patchver}_${bver}
        local lastrpath=jdk-${majorver}.${minorver}.${patchver}%2B${bver}
    else
        local verstr=${majorver}u${minorver}b${bver}
        local lastrpath=jdk${majorver}u${minorver}-b${bver}
    fi
    local file=OpenJDK${majorver}U-${app}_${arch}_${os}_hotspot_${verstr}.${archivetype}
    local rpath=temurin${majorver}-binaries/releases/download/$lastrpath
    local checksums=${file}.sha256.txt

    local rfileurl=$MIRROR/$rpath/$file
    local rchecksumsurl=$MIRROR/$rpath/$checksums
    local lchecksums=$DIR/$checksums

    if [ ! -e $lchecksums ];
    then
        curl -sSL -o $lchecksums -f $rchecksumsurl
    fi

    printf "        # %s\n" $rchecksumsurl
    printf "        %s: sha256:%s\n" $platform $(fgrep $file $lchecksums | awk '{print $1}')
}

dl_app() {
    local app=$1

    # 8, 11, 12
    local majorver=$2
    # 212, 0, 12
    local minorver=$3

    # N/A, 3, 0
    local patchver=$4

    # 04, 7, 12
    local bver=$5

    printf "      %s:\n" $app
    if [ $majorver -ge 9 ];
    then
        dl $app $majorver $minorver $patchver $bver alpine-linux x64
        dl $app $majorver $minorver $patchver $bver linux s390x
    fi
    dl $app $majorver $minorver $patchver $bver linux x64

    dl $app $majorver $minorver $patchver $bver windows x64 zip
    dl $app $majorver $minorver $patchver $bver windows x86-32 zip
    dl $app $majorver $minorver $patchver $bver linux aarch64
    dl $app $majorver $minorver $patchver $bver linux arm
    dl $app $majorver $minorver $patchver $bver linux ppc64le
    dl $app $majorver $minorver $patchver $bver mac x64

    if [ $majorver -le 12 ];
    then
        dl $app $majorver $minorver $patchver $bver aix ppc64
    fi

    if [ $majorver -ge 12 ];
    then
        dl $app $majorver $minorver $patchver $bver mac aarch64
    fi
}

dlall() {
    # 8, 11, 12
    local majorver=$1
    # 212, 0, 12
    local minorver=$2

    # N/A, 3, 0
    local patchver=$3

    # 04, 7, 12
    local bver=$4

    local verstr=""
    if [ $majorver -ge 9 ];
    then
        verstr="${majorver}.${minorver}.${patchver}_${bver}"
    else
        verstr="${majorver}u${minorver}b${bver}"
    fi

    printf "    '%s':\n" $verstr
    dl_app jdk $majorver $minorver $patchver $bver
    dl_app jre $majorver $minorver $patchver $bver
}

# https://adoptopenjdk.net/releases.html

dlall 8 312 'N/A' '07'
dlall 11 0 13 8
dlall 17 0 1 12
