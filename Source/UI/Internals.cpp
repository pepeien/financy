#include "Internals.hpp"

#include <QtDebug>
#include <QFileDialog>
#include "base64.hpp"

#include "Core/Helper.hpp"

namespace Financy
{
    QString Internals::openFileDialog(
        const QString& inTitle,
        const QString& inExtensions
    )
    {
        QString fileExtensions = "Files";
        fileExtensions.push_back(" (");
        for (std::string& fileExtension : Helper::splitString(inExtensions.toStdString(), ";"))
        {
            fileExtensions.push_back(QString::fromLatin1("*." + fileExtension + " "));
        }
        fileExtensions.push_back(")");

        return QFileDialog::getOpenFileUrl(
            nullptr,
            inTitle,
            QUrl::fromLocalFile("/"),
            fileExtensions
        ).toString();
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