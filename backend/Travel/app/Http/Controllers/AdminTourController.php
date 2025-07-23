<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Tour;
use Illuminate\Support\Facades\Storage;

class AdminTourController extends Controller
{
    public function index()
    {
        return response()->json(Tour::orderBy('id', 'desc')->get());
    }

    public function store(Request $request)
    {
        $fields = $request->validate([
            'title' => 'required|string|max:255',
            'location' => 'required|string|max:255',
            'reviews' => 'nullable|integer|min:0',
            'price' => 'required|numeric|min:0',
            'image' => 'nullable|image|max:2048'
        ]);

        if ($request->hasFile('image')) {
            $fields['image'] = $request->file('image')->store('tours', 'public');
        }

        $tour = Tour::create($fields);

        return response()->json(['message' => 'Tour créé', 'tour' => $tour], 201);
    }
    public function destroy($id)
{
    $tour = Tour::findOrFail($id);
    $tour->delete();
    return response()->json(['message' => 'Tour supprimé']);
}
public function show($id)
{
    return \App\Models\Tour::findOrFail($id);
}

public function update(Request $request, $id)
{
    $tour = \App\Models\Tour::findOrFail($id);
    $data = $request->validate([
        'title' => 'required|string|max:255',
        'location' => 'required|string|max:255',
        'price' => 'required|numeric',
        'reviews' => 'required|numeric',
        'image' => 'nullable|string|max:255',
    ]);
    $tour->update($data);
    return response()->json($tour);
}
}