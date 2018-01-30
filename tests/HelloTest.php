<?php

namespace Example\Tests;

use PHPUnit\Framework\TestCase;
use Example\Hello;

final class HelloTest extends TestCase
{
    public function testCanBeCreatedFromValidEmailAddress()
    {
        $this->assertInstanceOf(
            Hello::class,
            Hello::fromString('Universe')
        );
    }
}
