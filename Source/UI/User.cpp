#include "User.hpp"

#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>

#include <cvmatandqimage.h>

namespace Financy
{
    User::User()
        : m_id(0),
        m_firstName(""),
        m_lastName(""),
        m_picture(""),
        m_primaryColor("#FFFFFF"),
        m_secondaryColor("#000000")
    {}

    void User::fromJSON(const nlohmann::json& inData)
    {
        setFirstName(QString::fromLatin1((std::string) inData["firstName"]));
        setLastName(  QString::fromLatin1((std::string) inData["lastName"]));
        setPicture(    QString::fromLatin1((std::string) inData["picture"]));
    }

    uint32_t User::getId()
    {
        return m_id;
    }

    void User::setId(uint32_t inId)
    {
        m_id = inId;
    }

    QString User::getFirstName()
    {
        return m_firstName;
    }

    void User::setFirstName(const QString& inFirstName)
    {
        if (inFirstName.isEmpty())
        {
            return;
        }

        m_firstName = inFirstName;
    }

    QString User::getLastName()
    {
        return m_lastName;
    }

    void User::setLastName(const QString& inLastName)
    {
        if (inLastName.isEmpty())
        {
            return;
        }

        m_lastName = inLastName;
    }

    QString User::getPicture()
    {
        return m_picture;
    }

    void User::setPicture(const QString& inPicture)
    {
        m_picture = inPicture;

        // TODO Read these values from JSON <- set it on profile register or edit
        setDominantColors();
    }

    void User::setDominantColors()
    {
        QStringList splittedData = m_picture.split(',');

        QImage image;
        image.loadFromData(
            QByteArray::fromBase64(
                splittedData.at(splittedData.size() - 1).toUtf8()
            )
        );

        cv::Scalar prominentColor = cv::mean(
            QtOcv::image2Mat(image)
        );

        m_primaryColor = QColor(
           prominentColor[0], // R
           prominentColor[1], // G
           prominentColor[2]  // B
        );

        m_secondaryColor = QColor(
           255 - m_primaryColor.red(),
           255 - m_primaryColor.green(),
           255 - m_primaryColor.blue()
        );
    }
}