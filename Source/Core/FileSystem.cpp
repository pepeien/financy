#include "FileSystem.hpp"

#include <iostream>
#include <filesystem>
#include <fstream>

#if OS_WINDOWS
    #include <windows.h>
    #include <tchar.h>
    #include <shellapi.h>
#endif

#if OS_LINUX
    #include <cstdlib>
#endif

#include "Helper.hpp"

namespace Financy
{
    namespace FileSystem
    {
        void openFile(const std::string& inFilePath)
        {
            if (!doesFileExist(inFilePath))
            {
                return;
            }

            const std::filesystem::path filepath = std::filesystem::absolute(inFilePath);

            #if OS_WINDOWS
                ShellExecuteW(NULL, L"open", filepath.wstring().c_str(), NULL, NULL, SW_SHOWDEFAULT);
            #elif OS_LINUX
                const std::string command = "xdg-open \"" + filepath.string() + "\" &";

                system(command.c_str());
            #endif
        }

        FileResult openFileDialog(
            const std::string& inTitle,
            const std::vector<FileFormat>& inFileFormats
        )
        {
            #if OS_WINDOWS
                std::string fileFormatExtensions = "";

                for (FileFormat fileFormat : inFileFormats)
                {
                    fileFormatExtensions.append("*." + fileFormat.extension + ";");
                }

                std::string fileFilter = "All Files (" + fileFormatExtensions + ")";
                fileFilter.push_back('\0');
                fileFilter += fileFormatExtensions;
                fileFilter.push_back('\0');

                for (FileFormat fileFormat : inFileFormats)
                {
                    fileFilter += fileFormat.title + " (*." + fileFormat.extension + ")";
                    fileFilter.push_back('\0');
                    fileFilter += "*." + fileFormat.extension + ";";
                    fileFilter.push_back('\0');
                }
                fileFilter.push_back('\0');

                OPENFILENAME ofn;
                ZeroMemory(&ofn, sizeof(ofn));

                ofn.lStructSize  = sizeof( ofn );
                ofn.hwndOwner    = NULL;

                wchar_t* filepath = new wchar_t();
                ZeroMemory(filepath, sizeof(filepath));

                ofn.lpstrFile    = filepath;
                ofn.nMaxFile     = MAX_PATH;
                ofn.Flags        = OFN_DONTADDTORECENT | OFN_FILEMUSTEXIST;

                std::wstring sFileFilter = std::wstring(fileFilter.begin(), fileFilter.end());
                ofn.lpstrFilter = sFileFilter.c_str();
    
                std::wstring sInTitle = std::wstring(inTitle.begin(), inTitle.end());
                ofn.lpstrTitle = sInTitle.c_str();

                if (GetOpenFileName(&ofn))
                {
                    std::wstring filePathWString(ofn.lpstrFile);
                    std::string filePathString(filePathWString.begin(), filePathWString.end());

                    std::vector<std::string> splittedFilepath = Helper::splitString(
                        filePathString,
                        "."
                    );

                    delete filepath;

                    return {
                        filePathString,
                        splittedFilepath[splittedFilepath.size() - 1]
                    };
                }

                return {};
            #elif OS_LINUX
                return {};
            #endif
        }

        bool doesFileExist(const std::string& inFilepath)
        {
            std::fstream f(inFilepath.c_str());

            return f.good();
        }

        std::vector<char> readFile(const std::string& inFilepath)
        {
            std::ifstream file(inFilepath, std::ios::ate | std::ios::binary);

            if (file.is_open() == false)
            {
                throw std::runtime_error("Failed to open file -> " + inFilepath);
            }
    
            size_t fileSize = (size_t)file.tellg();
            std::vector<char> buffer(fileSize);
    
            file.seekg(0);
            file.read(buffer.data(), fileSize);
            file.close();
    
            return buffer;
        }
    }
}