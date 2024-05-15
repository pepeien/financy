#include "Application.hpp"

#include "FileSystem.hpp"

#include "UI/Internal.hpp"

namespace Financy
{
    Application::Application()
    {}

    Application::Application(const std::string& inTitle)
        : Application(
            inTitle,
            Colors::Theme::Light
        )
    {}

    Application::Application(const std::string& inTitle, Colors::Theme inTheme)
        : m_title(inTitle),
        m_theme(inTheme)
    {}

    int Application::run(int argc, char *argv[])
    {
        QApplication app(argc, argv);

        QQuickView viewer;
        viewer.setFlags(Qt::WindowType::Window | Qt::WindowType::FramelessWindowHint);
        viewer.setResizeMode(QQuickView::SizeRootObjectToView);
        viewer.setMinimumWidth(1600);
        viewer.setMinimumHeight(900);
        viewer.setTitle(QString::fromStdString(m_title));
        viewer.setColor("transparent");

        QQmlContext* content = viewer.rootContext();

        // Internals
        std::unique_ptr<Internal> m_internal = std::make_unique<Internal>();
        content->setContextProperty(
            "internal",
            m_internal.release()
        );

        viewer.setSource(QUrl("qrc:/Pages/Root.qml"));

        QObject::connect(
            viewer.engine(),
            &QQmlEngine::quit,
            &viewer,
            &QWindow::close
        );

        viewer.show();

        return app.exec();
    }
}