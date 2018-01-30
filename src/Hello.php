<?php

namespace Example;

class Hello
{
    public function hello($name = null)
    {
        if (!$name) {
            $name = 'World';
        }
        return "Hello, " . $name;
    }

    public static function fromString($name)
    {
        return new self($name);
    }
}
