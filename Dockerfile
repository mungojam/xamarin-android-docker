FROM mungojam/mono-build

RUN apt-get install lynx wget curl unzip openjdk-8-jdk libzip4 -y && \
    apt-get clean all
    
RUN mkdir -p /android/sdk && \
    curl -k https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip -o sdk-tools-linux-3859397.zip && \
    unzip -q sdk-tools-linux-3859397.zip -d /android/sdk && \
    rm sdk-tools-linux-3859397.zip

RUN cd /android/sdk && \
    yes | ./tools/bin/sdkmanager --licenses && \
    ./tools/bin/sdkmanager 'build-tools;28.0.3' platform-tools 'platforms;android-28' 'ndk-bundle'

RUN lynx -listonly -dump https://jenkins.mono-project.com/view/Xamarin.Android/job/xamarin-android-linux/lastSuccessfulBuild/Azure/ | grep -o "https://.*/Azure/processDownloadRequest/xamarin-android/xamarin.android-oss_v.*-Release.tar.bz2" > link.txt && \
    curl -L $(cat link.txt) \
        -o xamarin.tar.bz2 && \
    bzip2 -cd xamarin.tar.bz2 | tar -xvf - && \
    mv xamarin.android-oss_v* /android/xamarin && \
    ln -s /android/xamarin/bin/Release/lib/xamarin.android/xbuild/Xamarin /usr/lib/mono/xbuild/Xamarin && \
    ln -s /android/xamarin/bin/Release/lib/xamarin.android/xbuild-frameworks/MonoAndroid/ /usr/lib/mono/xbuild-frameworks/MonoAndroid && \
    rm xamarin.tar.bz2
    
ENV ANDROID_NDK_PATH=/android/sdk/ndk-bundle
ENV ANDROID_HOME=/android/sdk
ENV PATH=/android/xamarin/bin/Debug/bin:$PATH
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
