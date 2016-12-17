class A
{
public:
    A() : _val(0) {}
    virtual ~A() {}
private:
    int _val;
};

static A sA;
