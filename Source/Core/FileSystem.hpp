#pragma once

#include <string>
#include <vector>

#include "Base.hpp"

namespace Financy
{
    namespace FileSystem
    {
        struct FileFormat
        {
            std::string title     = "";
            std::string extension = "";
        };

        struct FileResult
        {
            std::string path      = "";
            std::string extension = "";
        };

        void openFile(const std::string& inFilePath);

        FileResult openFileDialog(
            const std::string& inTitle,
            const std::vector<FileFormat>& inFileFormats
        );

        bool doesFileExist(const std::string& inFilepath);
        std::vector<char> readFile(const std::string& inFilepath);
    }
}