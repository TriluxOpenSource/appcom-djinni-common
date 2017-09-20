//
//  CppLogger.hpp
//
//  Created by Ralph-Gordon Paul on 15.09.2017
//  Copyright (c) 2017 Ralph-Gordon Paul. All rights reserved.
//

#pragma once

#include <Logger.hpp>
#include <LogLevel.hpp>

#if defined(__ANDROID__)
extern "C" {
#include <android/log.h>
}
#endif

#include <boost/log/expressions/keyword.hpp>
#include <boost/log/sources/severity_logger.hpp>
#include <boost/log/trivial.hpp>

#include <string>

namespace appcom
{
#if defined(__ANDROID__)
BOOST_LOG_ATTRIBUTE_KEYWORD(module, "Module", std::string)
#endif

class CppLogger : Logger
{
public:
  /** initialise the logger for the specified loglevel (needs to be called once for all libraries that use this) */
  static void init(LogLevel loglevel = LogLevel::ERROR);

#if defined(__ANDROID__)
  //! converts boost log level to android log level (log priority)
  static android_LogPriority boostLogLevelToAndroid(boost::log::trivial::severity_level loglevel);
#endif

private:
  CppLogger() = delete;
  CppLogger(const CppLogger &other) = delete;

  static boost::log::trivial::severity_level logLevelToBoost(LogLevel loglevel);
};
} // namespace appcom
