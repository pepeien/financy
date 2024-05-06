#include "Internals.hpp"

#include <QtDebug>
#include "base64.hpp"

#include "Core/Helper.hpp"
#include "Core/FileSystem.hpp"

namespace Financy
{
    QString Internals::openFileDialog(
        const QString& inTitle,
        const QString& inExtensions
    )
    {
        std::vector<FileSystem::FileFormat> fileFormats;

        for (std::string& extension : Helper::splitString(inExtensions.toStdString(), ";"))
        {
            FileSystem::FileFormat fileFormat;
            fileFormat.title = extension;
            fileFormat.extension = extension;

            fileFormats.push_back(fileFormat);
        }

        FileSystem::FileResult file = FileSystem::openFileDialog(
            inTitle.toStdString(),
            fileFormats
        );
    
        std::vector<char> raw = FileSystem::readFile(file.path);
        std::string sRaw(raw.begin(), raw.end());

        return QString::fromLatin1("data:image/" + file.extension + ";base64," + base64::to_base64(sRaw));
    }

    void Internals::updateTheme(Colors::Theme inTheme)
    {
        if (!m_colors)
        {
            return;
        }

        switch (inTheme)
        {
        case Colors::Theme::Dark:
            m_colors->setBackgroundColor("#0C1017");
            m_colors->setForegroundColor("#08374A");
            m_colors->setLightColor("#006A74");
            m_colors->setDarkColor("#049E84");

            return;

        case Colors::Theme::Light:
        default:
            m_colors->setBackgroundColor("#E1F7F5");
            m_colors->setForegroundColor("#D9D9D9");
            m_colors->setLightColor("#596B5D");
            m_colors->setDarkColor("#39473C");

            return;
        }
    }

    void Internals::addUser(
        const QString& inFirstName,
        const QString& inLastName,
        const QUrl& inPicture
    )
    {
        qDebug() << "First Name - " << inFirstName << " Last Name - " << inLastName << " Picture - " << inPicture;
    }
}