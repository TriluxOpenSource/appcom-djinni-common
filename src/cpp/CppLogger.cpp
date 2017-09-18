//
//  CppLogger.cpp
//
//  Created by Ralph-Gordon Paul on 15.09.2017
//  Copyright (c) 2017 Ralph-Gordon Paul. All rights reserved.
//

#include "CppLogger.hpp"

#include <boost/log/attributes.hpp>
#include <boost/log/sources/record_ostream.hpp>
#include <boost/log/core.hpp>
#include <boost/log/expressions.hpp>
#include <boost/log/sinks.hpp>
#include <boost/log/sources/logger.hpp>
#include <boost/log/utility/setup.hpp>

#include <mutex>

using namespace appcom;

#if defined(__ANDROID__)
struct android_sink_backend : public boost::log::sinks::basic_sink_backend<boost::log::sinks::concurrent_feeding>
{
    void consume(const boost::log::record_view &rec)
    {
        // get severity level from boost
        const boost::log::trivial::severity_level loglevel = rec[boost::log::trivial::severity].get();
        // get log message from boost
        const char *message = rec[boost::log::expressions::smessage].get().c_str();

        android_LogPriority logPriority = CppLogger::boostLogLevelToAndroid(loglevel);

        const char *logmodule = "Native";

        // if there was a module name specified, we will use that
        if (rec[appcom::module])
        {
            logmodule = rec[appcom::module].get().c_str();
        }

        // forward to actual logging function
        __android_log_print(logPriority, logmodule, "%s", message);
    }
};
#endif

void Logger::init(LogLevel loglevel)
{
    CppLogger::init(loglevel);
}

void CppLogger::init(LogLevel loglevel)
{
    static std::mutex mutex;
    static bool isAlreadyInitialised{false}; // only initialise once

    mutex.lock();
    if (!isAlreadyInitialised)
    {
        boost::log::add_common_attributes();
        boost::log::trivial::severity_level level = logLevelToBoost(loglevel);

#if defined(__ANDROID__)
        typedef boost::log::sinks::synchronous_sink<android_sink_backend> android_sink;
        boost::shared_ptr<android_sink> sink = boost::make_shared<android_sink>();

        sink->set_filter(boost::log::trivial::severity >= level);
        boost::log::core::get()->add_sink(sink);
#endif
        isAlreadyInitialised = true;
    }
    mutex.unlock();
}

#if defined(__ANDROID__)
android_LogPriority CppLogger::boostLogLevelToAndroid(boost::log::trivial::severity_level loglevel)
{
    // create an android log level
    android_LogPriority logPriority = ANDROID_LOG_SILENT;

    // convert boost::log::trivial::severity_level to android log level
    switch (loglevel)
    {
    case boost::log::trivial::trace:
        logPriority = ANDROID_LOG_VERBOSE;
        break;

    case boost::log::trivial::debug:
        logPriority = ANDROID_LOG_DEBUG;
        break;

    case boost::log::trivial::info:
        logPriority = ANDROID_LOG_INFO;
        break;

    case boost::log::trivial::warning:
        logPriority = ANDROID_LOG_WARN;
        break;

    case boost::log::trivial::error:
        logPriority = ANDROID_LOG_ERROR;
        break;

    case boost::log::trivial::fatal:
        logPriority = ANDROID_LOG_FATAL;
        break;
    }

    return logPriority;
}
#endif

void appcom::setModule(boost::log::sources::severity_logger<boost::log::trivial::severity_level> &logger,
                       const std::string &name)
{
    logger.add_attribute(module.get_name(), boost::log::attributes::constant<std::string>(name));
}

// ---------------------------------------------------------------------------------------------------------------------
// Private
// ---------------------------------------------------------------------------------------------------------------------

boost::log::trivial::severity_level CppLogger::logLevelToBoost(LogLevel loglevel)
{
    boost::log::trivial::severity_level level = boost::log::trivial::trace;

    switch (loglevel)
    {
    case LogLevel::TRACE:
        level = boost::log::trivial::trace;
        break;
    case LogLevel::DEBUG:
        level = boost::log::trivial::debug;
        break;
    case LogLevel::INFO:
        level = boost::log::trivial::info;
        break;
    case LogLevel::WARNING:
        level = boost::log::trivial::warning;
        break;
    case LogLevel::ERROR:
        level = boost::log::trivial::error;
        break;
    case LogLevel::FATAL:
        level = boost::log::trivial::fatal;
        break;
    }

    return level;
}
