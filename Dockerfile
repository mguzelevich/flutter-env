FROM ubuntu:latest

# Prerequisites
RUN apt update && apt install -y build-essential curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget gnupg less lsof net-tools apt-utils

# DART
RUN apt install apt-transport-https
RUN sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
RUN sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
RUN apt update
RUN apt install dart -y
ENV PATH="${PATH}:/usr/lib/dart/bin/"
ENV PATH="${PATH}:/root/.pub-cache/bin"

RUN pub global activate webdev
RUN pub global activate stagehand

# Setup new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Prepare Android directories and system variables
RUN mkdir -p Android/Sdk
ENV ANDROID_SDK_ROOT /home/developer/Android/Sdk
RUN mkdir -p .android && touch .android/repositories.cfg

# Setup Android SDK
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/Sdk/tools

# RUN curl  https://dl.google.com/android/repository/addons_list-3.xml

# RUN cd Android/Sdk/tools/bin

# Install Android Tools
RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager --update --verbose

RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "build-tools;28.0.3" --verbose
RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "build-tools;29.0.3" --verbose
RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "patcher;v4" --verbose
RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "platform-tools"
RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "platforms;android-28" --verbose
RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "platforms;android-29" --verbose
RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "sources;android-28" --verbose
RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "sources;android-29" --verbose

RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "emulator" --verbose
# RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "system-images;android-28;default;armeabi-v7a"
RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "system-images;android-28;default;x86_64"
RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "system-images;android-29;default;x86_64"

# RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "extras;android;m2repository" --verbose
# RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "extras;google;m2repository" --verbose
# RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2" --verbose
# RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" --verbose
# RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager "system-images;android-28;google_apis;x86" --verbose

RUN cd Android/Sdk/tools/bin && yes | ./sdkmanager --licenses 

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/developer/flutter/bin"

# firebase cli - https://firebase.tools/
RUN mkdir -p /home/developer/bin
RUN curl -Lo /home/developer/bin/firebase https://firebase.tools/bin/linux/latest
RUN chmod a+x /home/developer/bin/firebase
ENV PATH "$PATH:/home/developer/bin"

# Run basic check to download Flutter SDK
RUN flutter channel dev
RUN flutter upgrade
RUN flutter doctor -v
