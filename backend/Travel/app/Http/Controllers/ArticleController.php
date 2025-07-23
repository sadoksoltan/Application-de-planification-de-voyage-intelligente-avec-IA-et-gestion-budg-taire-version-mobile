<?php
namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Article;

class ArticleController extends Controller
{
    // Liste des articles pour l'admin
    public function index()
    {
        return Article::orderBy('created_at', 'desc')->get();
    }

    // Création d'un article avec upload d'image
    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'category' => 'nullable|string|max:100',
            'author' => 'nullable|string|max:100',
            'published_date' => 'nullable|date',
            'image' => 'nullable|file|image|max:4096',
            'description' => 'nullable|string',
        ]);

        // Gérer l'upload de l'image si présente
        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('articles', 'public');
        }

        $article = Article::create($data);
        return response()->json($article, 201);
    }
    public function publicIndex()
{
    return Article::orderBy('created_at', 'desc')->get([
        'id', 'title', 'description', 'category', 'image', 'author', 'published_date'
    ]);
}
public function destroy($id)
{
    $article = Article::findOrFail($id);
    $article->delete();
    return response()->json(['message' => 'Article supprimé']);
}
public function show($id)
{
    return \App\Models\Article::findOrFail($id);
}

public function update(Request $request, $id)
{
    $article = \App\Models\Article::findOrFail($id);
    $data = $request->validate([
        'title' => 'required|string|max:255',
        'category' => 'nullable|string|max:100',
        'author' => 'nullable|string|max:100',
        'published_date' => 'nullable|date',
        'image' => 'nullable|string|max:255',
        'description' => 'nullable|string',
    ]);
    $article->update($data);
    return response()->json($article);
}
}