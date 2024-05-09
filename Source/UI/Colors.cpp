#include "Colors.hpp"

#include <QQmlEngine>

namespace Financy
{
    Colors::Colors(QObject* parent)
        : QObject(parent),
        m_background("#FFFFFF"),
        m_foreground("#000000"),
        m_light("#FFFFFF"),
        m_dark("#000000")
    {
        qmlRegisterUncreatableType<Colors>(
            "Financy.Colors",
            1,
            0,
            "Colors",
            "Internal use only"
        );
    }

    void Colors::setBackgroundColor(const QColor& inColor)
    {
        m_background = inColor;

        emit colorsChanged();
    }

    QColor Colors::getBackgroundColor()
    {
        return m_background;
    }

    void Colors::setForegroundColor(const QColor& inColor)
    {
        m_foreground = inColor;

        emit colorsChanged();
    }

    QColor Colors::getForegroundColor()
    {
        return m_foreground;
    }

    void Colors::setLightColor(const QColor& inColor)
    {
        m_light = inColor;

        emit colorsChanged();
    }

    QColor Colors::getLightColor()
    {
        return m_light;
    }

    void Colors::setDarkColor(const QColor& inColor)
    {
        m_dark = inColor;

        emit colorsChanged();
    }

    QColor Colors::getDarkColor()
    {
        return m_dark;
    }
}