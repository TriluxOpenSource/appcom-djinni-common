//
//  cpp_platform_threads.hpp
//
//  Created by Ralph-Gordon Paul on 23.08.2017
//  Copyright (c) 2017 appcom interactive GmbH. All rights reserved.
//

#include <platform_threads.hpp>
#include <thread_func.hpp>

#include <functional>
#include <thread>

namespace appcom {

template <typename ThreadFuncPtr>
class CppPlatformThreadsGeneric : public PlatformThreads {
public:
    CppPlatformThreadsGeneric() : m_func_on_thread_start(nullptr) {};

    CppPlatformThreadsGeneric(std::function<void()> func_on_thread_start)
    : m_func_on_thread_start(make_shared<std::function<void()>>(std::move(func_on_thread_start))) {}

    virtual void create_thread(const std::string & /*name*/,
                               const ThreadFuncPtr & func) override final {
        std::thread([run_func=std::move(func), start_func=m_func_on_thread_start]() {
            if (start_func && *start_func) {
                (*start_func)();
            }
            run_func->run();
        }).detach();
    }

    virtual std::experimental::optional<bool> is_main_thread() override final {
        return nullopt;
    }

private:
    const shared_ptr<std::function<void()>> m_func_on_thread_start;
};

using CppPlatformThreads = CppPlatformThreadsGeneric<std::shared_ptr<ThreadFunc>>;

class ThreadFuncImpl final : public ThreadFunc {
public:

    ThreadFuncImpl(std::function<void()> func) : m_func(std::move(func)) {}

    virtual void run() override final {
        m_func();
    }
private:
    const std::function<void()> m_func;
};

} // namespace appcom
