IsEqualGUID(guid1, guid2)
{
    return DllCall("ole32\IsEqualGUID", "ptr", &guid1, "ptr", &guid2)
}