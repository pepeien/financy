#include "Application.hpp"

#include "FileSystem.hpp"

namespace Financy
{
    Application::Application()
    {}

    Application::Application(const std::string& inTitle)
        : Application(
            inTitle,
            ETheme::DARK
        )
    {}

    Application::Application(const std::string& inTitle, ETheme inTheme)
        : m_title(inTitle),
        m_colors(std::make_unique<ColorScheme>())
    {
        updateTheme(inTheme);
        setupUsers();
    }

    Application::~Application()
    {
        for (User* user : m_users)
        {
            delete user;
        }
    }

    void Application::updateTheme(ETheme inTheme)
    {
        switch (inTheme)
        {
        case ETheme::DARK:
            m_colors->setBackgroundColor("#0C1017");
            m_colors->setForegroundColor("#08374A");
            m_colors->setLightColor("#006A74");
            m_colors->setDarkColor("#049E84");

            return;

        case ETheme::LIGHT:
        default:
            m_colors->setBackgroundColor("#E1F7F5");
            m_colors->setForegroundColor("#D9D9D9");
            m_colors->setLightColor("#596B5D");
            m_colors->setDarkColor("#39473C");

            return;
        }
    }

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

        // Color Scheme
        content->setContextProperty(
            "colorScheme",
            m_colors.release()
        );

        // Users
        content->setContextProperty(
            "users",
            QVariant::fromValue(m_users)
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

    void Application::setupUsers()
    {
        std::string usersFileLocation = "Users.json";

        if (!FileSystem::doesFileExist(usersFileLocation))
        {
            return;
        }

        std::vector<char> userRaw = FileSystem::readFile(usersFileLocation);

        rapidjson::Document userDoc;
        userDoc.Parse(
            std::string(
                userRaw.begin(),
                userRaw.end()
            ).c_str()
        );

        if (userDoc.Empty())
        {
            return;
        }

        for (auto itr = userDoc.Begin(); itr != userDoc.End(); ++itr) {
            Financy::User* user = new Financy::User();
            user->fromJSON(itr->GetObject());

            m_users.push_back(user);
        }
    }
}