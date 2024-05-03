#include "FileSystem.hpp"

#include <fstream>

#ifdef OS_WINDOWS
    #include <windows.h>
    #include <tchar.h>
#endif

#include "Helper.hpp"

namespace Financy
{
    namespace FileSystem
    {
        FileResult openFileDialog(
            const std::string& inTitle,
            const std::vector<FileFormat>& inFileFormats
        )
        {
            #ifdef OS_WINDOWS
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

                std::wstring filePathWString(filepath);
                std::string filePathString(filePathWString.begin(), filePathWString.end());

                if (GetOpenFileName(&ofn))
                {
                    std::vector<std::string> splittedFilepath = Helper::splitString(
                        filePathString,
                        "."
                    );

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