using System;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using Microsoft.Extensions.Logging.Console;
using Docker.DotNet;
using Docker.DotNet.Models;
using Microsoft.Extensions.Logging;
using ByteSizeLib;
using Toradex.Utils;


namespace Toradex.Utils
{
    public static class Docker
    {
        public class DockerJsonSystemDf
        {
            public string Active { get; set; }
            public string Reclaimable { get; set; }
            public string Size { get; set; }
            public string TotalCount { get; set; }
        }

        public class DockerImageRecord
        {
            public string Name { get; set; }
            public string Tag { get; set; }
            public string ImageId { get; set; }
            public string Created { get; set; }
            public string Size { get; set; }
            public string InUse { get; set; }
            public string InUseVisible { get; set; }
        }

        public class DockerContainerRecord
        {
            public string Name { get; set; }
            public string Tag { get; set; }
            public string Image { get; set; }
            public string State { get; set; }
            public string Icon { get; set; }
        }

        static public DockerClient client;
        static private DockerJsonSystemDf dockerJsonSystemDf;

        public static void Connect()
        {

            Utils.Logger.LogDebug("Trying to connecto to Docker daemon ...");

            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                Utils.Logger.LogDebug("Runnning on Windows");

                client = new DockerClientConfiguration(
                    new Uri("npipe://./pipe/docker_engine"))
                        .CreateClient();
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            {
                Utils.Logger.LogDebug("Runnning on Linux");

                client = new DockerClientConfiguration(
                    new Uri("unix:///var/run/docker.sock"))
                        .CreateClient();
            }
            else
            {
                throw new Exception("Not supported OS Platform");
            }
        }

        public static async Task<string> GetVersion()
        {
            var dockerVersion = await client.System.GetVersionAsync();
            return dockerVersion.Version;
        }

        public static async Task<List<DockerContainerRecord>> GetContainers()
        {
            IList<ContainerListResponse> containers =
                await client.Containers.ListContainersAsync(
                    new ContainersListParameters(){
                        All = true
                    });
            
            Utils.Logger.LogDebug($"Images found::{containers.Count}");
            List<DockerContainerRecord> containerRecords = new List<DockerContainerRecord>();

            foreach (var cont in containers) {
                var record = new DockerContainerRecord();
                record.Image = cont.Image.Replace("/", "");
                record.State = cont.State.ToUpper();
                record.Icon = cont.State.Equals("running") ? "Assets/Images/containerRunning.png" : "Assets/Images/containerFreeze.png";
                record.Name = cont.Names?[0].LimitLength(30);
                record.Tag = cont.Names?[0];
                containerRecords.Add(record);
            }

            return containerRecords;
        }

        public static async Task<List<DockerImageRecord>> GetImages()
        {
            IList<ImagesListResponse> images =
                await client.Images.ListImagesAsync(
                    new ImagesListParameters(){});

            IList<ContainerListResponse> containers =
                await client.Containers.ListContainersAsync(
                    new ContainersListParameters(){
                        All = true
                    });

            Utils.Logger.LogDebug($"Images found::{images.Count}");
            List<DockerImageRecord> imageRecords = new List<DockerImageRecord>();

            foreach (var img in images) {
                var record = new DockerImageRecord();
                record.Created = $"{Utils.GetTimeSince(img.Created)}";
                record.ImageId = img.ID.Replace("sha256:", "").LimitLength(12);

                if (img.RepoDigests != null)
                    record.Name = $"{img.RepoDigests?[0].Split("@")?[0].LimitLength(23)}{(img.RepoDigests?[0].Split("@")?[0].Length > 23 ? "..." : "")}";
                else
                    record.Name = $"{img.RepoTags?[0].Split(":")?[0].LimitLength(23)}{(img.RepoTags?[0].Length > 23 ? "..." : "")}";
                
                record.Size = $"{ByteSize.FromBytes(img.Size)}";
                record.Tag = img.RepoTags?[0].Split(":")[1];
                record.InUseVisible = "Collapsed";

                foreach (var cont in containers) {
                    if (cont.ImageID == img.ID) {
                        record.InUse = "IN USE";
                        record.InUseVisible = "Visible";
                    }
                }

                imageRecords.Add(record);
            }

            return imageRecords;
        }

        public static void UpdateSystemInfoDf()
        {
            var ret = "docker system df --format \"{{json . }}\"".Shell();
            var retArr = ret.Split("\n");
            dockerJsonSystemDf = JsonSerializer.Deserialize<DockerJsonSystemDf>(retArr[0]);
        }

        public static string GetImagesTotalSize()
        {
            return dockerJsonSystemDf.Size;
        }

        public static int GetImagesReclaimable()
        {
            var splited = dockerJsonSystemDf.Reclaimable.Split("(");
            return int.Parse(splited[1].Replace("%)", ""));
        }

        public static async void RemoveImage(string id, Action callBack = null)
        {
            await client.Images.DeleteImageAsync(id, new ImageDeleteParameters() {
                Force = true,
                NoPrune = false
            });

            if (callBack != null) {
                callBack();
            }
        }
        
        public static async void StopContainer(string id, Action callBack = null)
        {
            await client.Containers.StopContainerAsync(id, new ContainerStopParameters());

            if (callBack != null) {
                callBack();
            }
        }

        public static async void RemoveContainer(string id, Action callBack = null)
        {
            await client.Containers.RemoveContainerAsync(id, new ContainerRemoveParameters() {
                Force = true
            });

            if (callBack != null) {
                callBack();
            }
        }

        public static async void RefreshContainer(string id, Action callBack = null)
        {
            await client.Containers.RestartContainerAsync(id, new ContainerRestartParameters());

            if (callBack != null) {
                callBack();
            }
        }
    }
}
