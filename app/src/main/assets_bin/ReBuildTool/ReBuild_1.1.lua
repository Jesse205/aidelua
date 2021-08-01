ToolInformation={version="1.1"}

function getMainProjectName(config)
  local firstInclude=config.include[1]
  return firstInclude:match("project:(.+)") or "app"
end

function buildProject(ProjectPath,MainConfig,BuildTool,install)
  require "import"
  notLoadTheme=true
  import "Jesse205"
  import "android.content.pm.PackageManager"
  import "apksigner.*"
  import "ReBuildTool"
  this.update(activity.getString(R.string.binpoject_creating_variables))
  local BinEvents={}
  local Assets={}
  local Libraries={}
  local MainAideluaPath=ReBuildTool.getAideLuaPathByProjectDir(ProjectPath)
  MainConfig=luajava.astable(MainConfig,true)
  --local MainConfig=ReBuildTool.getConfigByFilePath(MainAideluaPath.."/config.lua")
  local MainAppPath=("%s/%s"):format(ProjectPath,BuildTool.getMainProjectName(MainConfig))
  local BuildPath=MainAppPath.."/build"
  local BinPath=BuildPath.."/bin"
  local BinFile=File(BinPath)
  local TempPath=BinPath.."/AideLua_unzip"
  local TempFile=File(TempPath)
  local AssetsPath=TempPath.."/assets"
  local AssetsFile=File(AssetsPath)
  local LibraryPath=TempPath.."/lua"
  local LibraryFile=File(LibraryPath)
  local AppPathList={BinPath.."/app.apk",
    BinPath.."/app-debug.apk",
    BuildPath.."/outputs/apk/debug/app.apk",
    BuildPath.."/outputs/apk/debug/app-debug.apk",
    AppPath.Sdcard.."/Android/data/com.aide.ui/cache/apk/app.apk",}
  local AppPath
  local AppFile
  local RePackedApkPath=BinPath.."/app_aidelua.apk"--重新打包后的apk路径
  local ReleaseApkPath=(BinPath.."/%s_v%s.apk"):format(MainConfig.appName,"%s")--发布的apk路径
  local SignedApkPath=BinPath.."/app_aidelua_sign.apk"--已签名apk路径
  local signSucceed,signErr

  for index,content in ipairs(AppPathList) do
    local file=File(content)
    if file.isFile() then
      AppPath=content
      AppFile=file
      break
    end
  end
  if not(AppPath) then
    return activity.getString(R.string.binpoject_error_notfind)
  end

  for index,content in ipairs(MainConfig.include) do
    local type_,name=content:match("(.-):(.+)")
    if type_=="project" then
      local libraryPath=("%s/%s"):format(ProjectPath,name)
      local luaPath=libraryPath.."/src/main/luaLibs"
      local assetsPath=libraryPath.."/src/main/assets_bin"
      local luaFile=File(luaPath)
      local assetsFile=File(assetsPath)
      if luaFile.isDirectory() then
        table.insert(Libraries,luaFile)
      end
      if assetsFile.isDirectory() then
        table.insert(Assets,assetsFile)
      end
      --arrangementProject()
    end
  end
  function reverseTable(tab)
    local tmp={}
    local oldTableLength=table.size(tab)
    for index,content in ipairs(tab) do
      tmp[oldTableLength-index+1]=content
    end
    return tmp
  end

  this.update(activity.getString(R.string.binpoject_unzip))
  BinFile.mkdirs()
  LuaUtil.rmDir(TempFile)
  LuaUtil.unZip(AppPath,TempPath)

  this.update(activity.getString(R.string.binpoject_copying))
  for index,content in ipairs(reverseTable(Assets)) do
    LuaUtil.copyDir(content,AssetsFile)
  end

  for index,content in ipairs(reverseTable(Libraries)) do
    LuaUtil.copyDir(content,LibraryFile)
  end

  if MainConfig.compileLua~=false then
    function dumpFiles(file)
      for index,content in ipairs(luajava.astable(file.listFiles())) do
        if content.isDirectory() then
          dumpFiles(content)
         elseif content.name:find"%.lua$" then
          local path=content.getPath()
          local func,err=loadfile(path)
          if func then
            io.open(path,"w"):write(string.dump(func,true)):close()
           else
            return err
          end
          func=nil
          path=nil
         elseif content.name:find"%.aly$" then
          local path=content.getPath()
          local func,err=loadfile(path)
          local path=path:match("(.+)%.aly")..".lua"
          if func then
            io.open(path,"w"):write(string.dump(func,true)):close()
           else
            return err
          end
          func=nil
          path=nil
          content.delete()
         elseif content.name==".nomedia" then
          content.delete()
        end
      end
    end
    this.update(activity.getString(R.string.binpoject_compiling))
    dumpFiles(TempFile)
  end

  this.update(activity.getString(R.string.binpoject_zip))
  for index,content in ipairs(BinEvents)
    local beforePack=content.beforePack
    if beforePack then
      beforePack(BinPath)--BinPath：临时文件路径
    end
  end
  LuaUtil.zip(TempPath,BinPath,"app_aidelua.apk")

  this.update(activity.getString(R.string.binpoject_deleting))
  LuaUtil.rmDir(TempFile)

  if install then--要安装
    if Signer then--有签名工具
      this.update(activity.getString(R.string.binpoject_signing))
      signSucceed,signErr=pcall(Signer.sign,RePackedApkPath,SignedApkPath)
    end

    if not(signSucceed) then--没有签名成功
      return formatResStr(R.string.binpoject_error_signer,{RePackedApkPath})
      --return String.format(activity.getString(R.string.binpoject_error_signer),{signErr})
    end
    return true,SignedApkPath,ProjectPath,install
   else
    --将文件重命名为 软件每次_版本号 的形式
    local apkPAI=activity.getPackageManager().getPackageArchiveInfo(RePackedApkPath,PackageManager.GET_ACTIVITIES)
    local apkInfo=apkPAI.applicationInfo
    apkInfo.sourceDir=ReleaseApkPath
    apkInfo.publicSourceDir=ReleaseApkPath

    ReleaseApkPath=ReleaseApkPath:format(apkPAI.versionName)
    local ReleaseApkFile=File(ReleaseApkPath)

    this.update(formatResStr(R.string.binpoject_copying2,{ReleaseApkFile.getName()}))
    File(RePackedApkPath).renameTo(ReleaseApkFile)
    return true,ReleaseApkPath,ProjectPath,install
  end
end