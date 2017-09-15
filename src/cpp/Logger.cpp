//
//  Logger.cpp
//
//  Created by Ralph-Gordon Paul on 15.09.2017
//  Copyright (c) 2017 Ralph-Gordon Paul. All rights reserved.
//

#include "Logger.hpp"

#include <boost/log/attributes.hpp>
#include <boost/log/sources/record_ostream.hpp>
#include <boost/log/core.hpp>
#include <boost/log/expressions.hpp>
#include <boost/log/sinks.hpp>
#include <boost/log/sources/logger.hpp>
#include <boost/log/utility/setup.hpp>

#if defined(__ANDROID__)
extern "C" {
#include <android/log.h>
}
#endif

using namespace appcom;

#if defined(__ANDROID__)
struct android_sink_backend : public boost::log::sinks::basic_sink_backend<boost::log::sinks::concurrent_feeding>
{
    void consume(const boost::log::record_view &rec)
    {
        // get severity level from boost
        const boost::log::trivial::severity_level sev = rec[boost::log::trivial::severity].get();
        // get log message from boost
        const char *message = rec[boost::log::expressions::smessage].get().c_str();

        // create an android log level
        android_LogPriority loglevel = ANDROID_LOG_SILENT;

        // convert boost::log::trivial::severity_level to android log level
        switch (sev)
        {
        case boost::log::trivial::trace:
            loglevel = ANDROID_LOG_VERBOSE;
            break;

        case boost::log::trivial::debug:
            loglevel = ANDROID_LOG_DEBUG;
            break;

        case boost::log::trivial::info:
            loglevel = ANDROID_LOG_INFO;
            break;

        case boost::log::trivial::warning:
            loglevel = ANDROID_LOG_WARN;
            break;

        case boost::log::trivial::error:
            loglevel = ANDROID_LOG_ERROR;
            break;

        case boost::log::trivial::fatal:
            loglevel = ANDROID_LOG_FATAL;
            break;
        }

        const char *logmodule = "unknown";

        // if there was a module name specified, we will use that
        if (rec[appcom::logger::module])
        {
            logmodule = rec[appcom::logger::module].get().c_str();
        }

        // forward to actual logging function
        __android_log_print(loglevel, logmodule, "%s", message);
    }
};
#endif

void appcom::logger::init()
{
    boost::log::add_common_attributes();

#if defined(__ANDROID__)
    typedef boost::log::sinks::synchronous_sink<android_sink_backend> android_sink;
    boost::shared_ptr<android_sink> sink = boost::make_shared<android_sink>();

    sink->set_filter(boost::log::trivial::severity >= boost::log::trivial::info);
    boost::log::core::get()->add_sink(sink);
#endif
}

void appcom::logger::setModule(boost::log::sources::severity_logger<boost::log::trivial::severity_level> &logger,
                               const std::string &name)
{
    logger.add_attribute(module.get_name(), boost::log::attributes::constant<std::string>(name));
}
