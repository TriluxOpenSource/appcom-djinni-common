//
//  Logger.hpp
//
//  Created by Ralph-Gordon Paul on 15.09.2017
//  Copyright (c) 2017 Ralph-Gordon Paul. All rights reserved.
//

#pragma once

#include <boost/log/expressions/keyword.hpp>
#include <boost/log/sources/severity_logger.hpp>
#include <boost/log/trivial.hpp>

#include <string>

namespace appcom
{
namespace logger
{
BOOST_LOG_ATTRIBUTE_KEYWORD(module, "Module", std::string)

//! initialise logging
void init();

//! set the module to a specific name
void setModule(boost::log::sources::severity_logger<boost::log::trivial::severity_level> &logger,
               const std::string &name);

using Logger = boost::log::sources::severity_logger<boost::log::trivial::severity_level>;

} // namespace logger
} // namespace appcom
