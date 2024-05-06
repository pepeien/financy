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

    void Colors::setForegroundColor(const QColor& inColor)
    {
        m_foreground = inColor;

        emit colorsChanged();
    }

    void Colors::setLightColor(const QColor& inColor)
    {
        m_light = inColor;

        emit colorsChanged();
    }

    void Colors::setDarkColor(const QColor& inColor)
    {
        m_dark = inColor;

        emit colorsChanged();
    }
}