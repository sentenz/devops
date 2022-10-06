#ifndef MODERNIZE_USE_USING_HPP
#define MODERNIZE_USE_USING_HPP

namespace tidy {

template <class Iterator>
struct iterator_traits
{
    typedef typename Iterator::category iterator_category;
    typedef typename Iterator::value_type value_type;
    typedef typename Iterator::difference_type difference_type;
    typedef typename Iterator::pointer pointer;
    typedef typename Iterator::reference reference;
};

template <class InputIterator, class Distance>
void advance(InputIterator&, Distance)
{
    typename iterator_traits<InputIterator>::iterator_category category;
}

} // namespace tidy

#endif
