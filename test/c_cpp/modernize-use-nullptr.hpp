#ifndef MODERNIZE_USE_NULLPTR_HPP
#define MODERNIZE_USE_NULLPTR_HPP

#include <cstddef>

namespace tidy {

inline void bar(int*& p)
{
    p = NULL;
}

struct T
{
    int* p_ = 0;

    void foo(int* p = 0)
    {
        bar(p);
    }
};

} // namespace tidy

#endif
