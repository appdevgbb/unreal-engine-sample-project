FROM --platform=${BUILDPLATFORM:-linux/amd64} gbbpixel.azurecr.io/epicgames/unreal-engine:dev-4.27 AS build

COPY --chown=ue4:ue4 ./MyProject /project

WORKDIR  /project

RUN /home/ue4/UnrealEngine/Engine/Build/BatchFiles/RunUAT.sh \
    BuildCookRun \
    -utf8output \
    -platform=Linux \
    -clientconfig=Shipping \
    -serverconfig=Shipping \
    -project=/project/MyProject.uproject \
    -noP4 -nodebuginfo -allmaps \
    -cook -build -stage -prereqs -pak -archive \
    -archivedirectory=/project/Packaged 

FROM --platform=${BUILDPLATFORM:-linux/amd64} gbbpixel.azurecr.io/epicgames/unreal-engine:runtime-pixel-streaming
WORKDIR /home/ue4/project
COPY --from=build --chown=ue4:ue4 /project/Packaged/LinuxNoEditor ./

CMD ["/bin/bash", "-c", "./MyProject.sh -PixelStreamingIP=localhost  -PixelStreamingPort=8888 -RenderOffscreen -Unattended -ResX=1920 -ResY=1080 -Windowed -ForceRes -StdOut" ]
