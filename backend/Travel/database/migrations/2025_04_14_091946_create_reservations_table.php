<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
{
    Schema::create('reservations', function (Blueprint $table) {
        $table->id();
        $table->string('title')->nullable();
        $table->string('first_name');
        $table->string('last_name');
        $table->string('email');
        $table->string('phone')->nullable();
        $table->string('gender')->nullable();
        $table->date('dob')->nullable();
        $table->string('country');
        $table->string('city');
        $table->string('address_line1')->nullable();
        $table->string('address_line2')->nullable();
        $table->timestamps();
    });
}


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reservations');
    }
};
